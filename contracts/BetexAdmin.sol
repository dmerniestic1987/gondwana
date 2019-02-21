pragma solidity >= 0.5.0;
import "./BetexAccessControl.sol";

contract BetexAdmin is BetexAccessControl{
    //Apuesta mínima
    uint public minimumStake;
    
    //Comisión que se le cobra al ganador de la apuesta
    uint8 public commission;

    //Ganancias totales acumuladas
    uint internal gain;
    
    //Mercados de las apuestas
    mapping(uint128 => bool) internal marketsExists;  

    /**
     * @dev Verifica que haya un mínimo stake
     */
    modifier minStake(){
        require(msg.value >= minimumStake, "No llegó a la apuesta mínima");
        _;
    }

    /**
     * @dev Obtiene las ganancias acumuladas  hasta el momento
     * @return gain - Ganancias acumuladas hasta el momento
     */
    function getGains() public view onlyCFO() returns (uint)  {
        return gain;
    }

    /**
     * @dev Setea el monto mínimo de apuestas permitidos. Si la comisión es del 
     * @param _commission Es la comisión que le cobra al ganador de una apuesta
     */
    function setCommission(uint8 _commission) public onlyCFO(){
        require(_commission > 0 && _commission <= 100, "Porcentaje incorrecto");
        commission = _commission;
    }

    /**
     * @dev Setea el monto mínimo de apuestas permitidos
     * @param _minStake Mínimo permitido en wei
     */
    function setMinimunStake(uint _minStake) public onlyMarketManager(){
        minimumStake = _minStake;
    }

    /**
     * @dev Agrega un mercado a la base de datos
     * @param _marketIdLaursia Id en Laurasia
     */
    function addMarket(uint128 _marketIdLaursia) public onlyMarketManager(){
        marketsExists[_marketIdLaursia] = true;
    }    
}    