pragma solidity >= 0.5.0;
import "./BetexAccessControl.sol";

/**
 * @title BetexAdmin
 * @dev Este contrato permite configurar cuál es el mínimo de apuestas y las comisiones 
 *      que se le cobran al ganador del las apuestas. También permite administrar los 
 *      mercados. 
 */
contract BetexAdmin is BetexAccessControl{
    //Apuesta mínima
    uint public minimumStake;
    
    //Comisión que se le cobra al ganador de la apuesta
    uint8 public commission;

    //Ganancias totales acumuladas
    uint internal gain;
    
    //Estados de los mercados
    enum MarketStatus { ACTIVE      //Mercado Activo: Se puede apostar
                      , SUSPENDED   //Mercado suspendido: NO se puede apostar y espera a que finalice un evento
                      , CLOSED  }   //Cerrado: El mercado está cerrado

    event OpenMarket(uint128 marketId);
    event ClosedMarket(uint128 marketId);      
    event SuspendedMarket(uint128 marketId);            
    event SettedCommision(uint8 oldComission, uint8 newComission); 
    event SettedStake(uint oldMinStake, uint newMinStake); 

    struct Market {
        MarketStatus marketStatus; //Estado de la apuesta 
    }

    //Mercados de las apuestas
    mapping(uint128 => bool)   internal marketsExists;  
    mapping(uint128 => Market) internal markets; 

    /**
     * @dev Verifica que haya un mínimo stake
     */
    modifier minStake(){
        require(msg.value >= minimumStake, "No llegó a la apuesta mínima");
        _;
    }

    /**
     * @dev El mercado tiene que estar activo
     */
    modifier activeMarket(uint128 _marketId){
         //El mercado tiene que existir
        require(marketsExists[_marketId], "El mercado no existe");

        //El mercado tiene que existir
        require(markets[_marketId].marketStatus == MarketStatus.ACTIVE, "El mercado no está activo");
        _;       
    }

    /**
     * @dev El mercado tiene que estar activo o suspendido
     */
    modifier activeOrSupendedMarket(uint128 _marketId){
         //El mercado tiene que existir
        require(marketsExists[_marketId], "El mercado no existe");

        //El mercado tiene que existir
        require(markets[_marketId].marketStatus == MarketStatus.ACTIVE || 
                markets[_marketId].marketStatus == MarketStatus.SUSPENDED, 
                "El mercado no está activo");
        _;       
    }
    
    /**
     * @dev Obtiene el balance en Ether acumulado en el contrato
     * @return el balance acumulado del contrato
     */
    function getBalance() public view  onlyCFO() returns (uint){
        return address(this).balance;
    }

    /**
     * @dev Obtiene las ganancias acumuladas  hasta el momento
     * @return gain - Ganancias acumuladas hasta el momento
     */
    function getGains() public view onlyCFO() returns (uint)  {
        return gain;
    }

    /**
     * @dev Setea el monto mínimo de apuestas permitidos. El porcentaje que se le cobra
     *      es sobre el total que ganó
     * @param _commission Es la comisión que le cobra al ganador de una apuesta
     */
    function setCommission(uint8 _commission) public onlyCFO(){
        require(_commission > 0 && _commission <= 100, "Porcentaje incorrecto");
        uint8 oldComission = commission;
        commission = _commission;
        emit SettedCommision(oldComission, commission);
    }

    /**
     * @dev Setea el monto mínimo de apuestas permitidos
     * @param _minStake Mínimo permitido en wei
     */
    function setMinimunStake(uint _minStake) public onlyMarketManager(){
        uint oldMinStake = minimumStake;
        minimumStake = _minStake;
        emit SettedStake(oldMinStake, minimumStake);
    }

    /**
     * @dev Agrega un mercado a la base de datos
     * @param _marketIdLaursia Id en Laurasia
     */
    function openMarket(uint128 _marketIdLaursia) public onlyMarketManager(){
        marketsExists[_marketIdLaursia] = true;
        markets[_marketIdLaursia].marketStatus = MarketStatus.ACTIVE;
        emit OpenMarket(_marketIdLaursia);
    }    

    /**
     * @dev Suspende un mercado
     * @param _marketIdLaursia Id en Laurasia
     */
    function suspendMarket(uint128 _marketIdLaursia) public onlyMarketManager() 
                        activeMarket(_marketIdLaursia){
        markets[_marketIdLaursia].marketStatus = MarketStatus.SUSPENDED;
        emit SuspendedMarket(_marketIdLaursia); 
    }    

    /**
     * @dev Cierra un mercado
     * @param _marketIdLaursia Id en Laurasia
     */
    function closeMarket(uint128 _marketIdLaursia) public onlyMarketManager() 
                        activeOrSupendedMarket(_marketIdLaursia){
        markets[_marketIdLaursia].marketStatus = MarketStatus.CLOSED;   
        emit ClosedMarket(_marketIdLaursia);
    }
}    