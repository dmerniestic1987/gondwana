pragma solidity >= 0.5.0;
import "./BetexAccessControl.sol";

contract Betex is BetexAccessControl{
    event PlacedBet(address bettor, uint marketId, uint betId, uint odds, uint stake);

    enum BetType    { BACK, LAY }                                       
    enum BetStatus  { OPEN, FULL_MATCHED, CLOSED }   
    enum BetResult  { WINNER, LOOSER, PENDING }

    struct Bet{
        uint marketId;       //Clave del mercado. Se calcula: keccak256(marketId + Fecha Evento) 
        uint runnerId;          //Runner por el que se apuesta        
        uint odd;               //Es la cuota. El sistema sólo permite 2 decimal,
                                //como entereo. Por ejemplo 2,73 se guarda como 273. 
        uint stake;             //Es el monto apostado en WEI. Debe coincidir con msg.sender en la creación        
        uint matchedStake;      //Es la cantidad de diner que hasta el momento se pudo matchear contra otras apuestas. 
                                //Si stake == matchedStake significa que la apuesta quedó en OPEN_MATCHED
        BetType betType;        //Tipo de apuesta. Back: A favor, Lay: En contra
        BetResult result;       //Resultado final de la apuesta.  
        BetStatus betStatus;    //Estado de la apuesta
        uint[] matchedBets;     //IDs de las apuestas contra las que matcheó.   
    }
    
    //Mercados de las apuestas
    mapping(uint => bool) public marketsExists;  
    
    //Guarda las apuestas con ID único  
    Bet[] public bets;         
    
    //Permite obtener los indices de todas las puestas de una dirección en particular
    mapping(address => uint[]) internal ownerToBetsIndex; 
                                                         
    //Permite determinar al  emisor de una apuesta
    mapping(uint => address payable) internal betIndexToOwner;                                          

    //Agrupa las apuestas por tipo de Mercado.  //Key: MarketId  //Value: Id - array índices de bets
    mapping(uint => uint[]) public betsByMarket; 

    //Permite registrar la cantidad de dinero apostada por tipo de mercado                                  
    mapping(uint => uint) totalStakeByMarket;

    constructor() public {
        owner = msg.sender;
        marketManagerAddress = msg.sender;
        cfoAddress  = msg.sender;
    }

    /**
     * @dev Agrega un mercado a la base de datos
     * @param _marketIdLaursia Id en Laurasia
     */
    function addMarket(uint _marketIdLaursia) public onlyMarketManager(){
        marketsExists[_marketIdLaursia] = true;
    }

    /**
     * @dev Registra una nueva apuesta para un mercado y un runner determinado
     * @param _marketId Id en Laurasia
     * @param _runnerId Runner en Laurasia
     * @param _odd cuota. El valor decimal se transforma a uint. Si en al app el apostador ingresa 1.41, acá llega 141
     * @param _betType tipo de apuesta
     * @param _counterBetId ID de la apuesta contra la que se apuesta. Si es 0, y no
     */
    function placeBet(uint _marketId, uint _runnerId, uint _odd, BetType _betType, uint _counterBetId) external payable {
        bool firstBet = bets.length == 0;
        //El mercado tiene que existir
        if (!marketsExists[_marketId]){
            //Acá se va a la mierda
        }

        //Acá se va a la mierda porque no debería exisitir la apuesta
        if (_counterBetId > bets.length){

        }

        //Acá no se debería permitir apostar porque son del mismo tipo
        if (!firstBet && bets[_counterBetId].betType == _betType) {

        }

        //Obtenemos la cantidad de dinero apostada.
        uint stake = msg.value;

        //Creamos el el Bet y le asignamos un id Único
        uint betId = _createBet(_marketId, _runnerId, _odd, _betType, stake);

        //Incrementamos el stake acumulado por marcado
        totalStakeByMarket[_marketId] = totalStakeByMarket[_marketId] + stake;
        
        //Verificamos que no se la primera apuesta de la historia
        if (!firstBet){
            _matchBet(betId, stake, _counterBetId);
        }
    }

    /**
    * Intenta matchear una apuesta determinada
    */
    function _matchBet(uint _betId, uint _stake , uint _counterBetId ) internal{
        //Rescatamos las apuestas
        Bet storage counterBet = bets[_counterBetId];
        Bet storage bet = bets[_betId];

        //Verificamos que la contra apuesta esté Abierta
        if (BetStatus.OPEN == counterBet.betStatus){
            //Calculamos el total del stake disponible de la contraapuesta
            uint availableCounterStake = counterBet.stake - counterBet.matchedStake;
            
            //Si el stake disponible es 0, entonces deberíamos cerrar la 
            //contraapuesta y no realizar el matcheo de las apuestas
            if (availableCounterStake == 0){
                counterBet.betStatus = BetStatus.CLOSED;
            }

            //Si hay stake disponible, entonces hay que ver si se igualan
            //las apuestas
            else{
                //Caso 1: Las apuestas matchean completamente. Ambas se deben cerrar,
                //acutalizar el matchedStake y agregar el ID a la lista de matchedBets
                if (_stake == availableCounterStake){
                    counterBet.matchedStake += _stake;
                    bet.matchedStake += _stake;

                    counterBet.betStatus = BetStatus.CLOSED;
                    bet.betStatus = BetStatus.CLOSED;
                }

                //Caso 2: El monto de la apuesta es superior al disponible de la contrapuesta. Se debe 
                //acualizar el matchedStake y agrgear el ID a la lista de machtedBets de ambas
                //apuestas, pero sólo se debe cerrar la contraApuesta
                else if (_stake > availableCounterStake){
                    counterBet.betStatus = BetStatus.CLOSED;
                    counterBet.matchedStake += availableCounterStake;
                    bet.matchedStake += availableCounterStake;
                
                }
                //Caso 3. El stake de la apuesta es inferior al disponible en la contraapuesta. Se debe
                //actualizar el matchedStake de ambos y agregar el ID a la lista de de matched de ambas
                //apuestas, pero sólo se debe cerrar la apuesta.
                else {
                    bet.betStatus = BetStatus.CLOSED;
                    bet.matchedStake += _stake;
                    counterBet.matchedStake += _stake;
                }
                
                counterBet.matchedBets.push(_betId);
                bet.matchedBets.push(_counterBetId);
            }
        }
    }
    /**
     * @dev Crea una nueva apuesta y la agrega a la base.
     * @param _marketId Id en Laurasia
     * @param _runnerId Runner en Laurasia
     * @param _odd cuota. El valor decimal se transforma a uint. Si en al app el apostador ingresa 1.41, acá llega 141
     * @param _betType tipo de apuesta
     */
    function _createBet(uint _marketId, uint _runnerId, uint _odd, BetType _betType, uint _stake) internal returns(uint){
        //Creamos el el Bet y le asignamos un id Único
        uint betId = bets.push( Bet( _marketId
                                   , _runnerId
                                   , _odd
                                   , _stake
                                   , 0, _betType
                                   , BetResult.PENDING
                                   , BetStatus.OPEN
                                   , new uint[](0)) ) - 1;

        //Verificamos que no haya bufferOverflow
        require(betId == uint256(uint32(betId)));

        //Agregamos la apuesta al histórico del usuario
        ownerToBetsIndex[msg.sender].push(betId);
        
        //Guardamos al apostador
        betIndexToOwner[betId] = msg.sender;

        //Agregamos la apuesta a la base de Mercados
        betsByMarket[_marketId].push(betId);                        
    }
}