pragma solidity >= 0.5.0;
import "./BetexAdmin.sol";

contract BetexBase is BetexAdmin{
    event Print(string name, string info);
    event PlacedBet(address bettor, uint marketId, uint betId, uint odds, uint stake);

    enum BetType    { BACK, LAY }                                       
    enum BetStatus  { OPEN, FULL_MATCHED, CLOSED }   
    enum BetResult  { WINNER, LOOSER, PENDING }

    struct Bet{
        uint marketId;          //Clave del mercado. Se calcula: keccak256(marketId + Fecha Evento) 
        uint runnerId;          //Runner por el que se apuesta        
        uint odd;               //Es la cuota. El sistema sólo permite 2 decimal,
                                //como entereo. Por ejemplo 2,73 se guarda como 273. 
        uint stake;             //Es el monto apostado en WEI. Debe coincidir con msg.sender en la creación        
        uint matchedStake;      //Es la cantidad de diner que hasta el momento se pudo matchear contra otras apuestas. 
                                //Si stake == matchedStake significa que la apuesta quedó en OPEN_MATCHED
        BetType betType;        //Tipo de apuesta. Back: A favor, Lay: En contra
        BetResult result;       //Resultado final de la apuesta.  
        BetStatus betStatus;    //Estado de la apuesta 
    }

    //Guarda las apuestas con ID único  
    Bet[] public bets;         
    
    mapping(uint => uint[]) matchedBets;

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
        minimumStake = 0.01 ether;
        commission = 5; //Se cobra el 5% de comisión al ganador
        //Creamos el mercado y la apuesta génesis
        addMarket(0);
        _createBet( 0, 0, 1, BetType.BACK, 0, 0, BetResult.WINNER, BetStatus.CLOSED); 
    }
    
    /**
     * @dev Registra una nueva apuesta para un mercado y un runner determinado
     * @param _marketId Id en Laurasia
     * @param _runnerId Runner en Laurasia
     * @param _odd cuota. El valor decimal se transforma a uint. Si en al app el apostador ingresa 1.41, acá llega 141
     * @param _betType tipo de apuesta
     * @param _counterBetId ID de la apuesta contra la que se apuesta. Si es 0, significa que es un nuevo odd
     */
    function placeBet( uint _marketId, uint _runnerId, uint _odd
                     , BetType _betType, uint _counterBetId) external payable minStake(){
        //El mercado tiene que existir
        require(marketsExists[_marketId], "El mercado no existe");
        
        //El ID no puede ser mayor a la cantiddad de total de elementos
        require(_counterBetId < bets.length, "El ID de la contraapuesta no existe");

        //Obtenemos la cantidad de dinero apostada.
        uint stake = msg.value;

        //Creamos el el Bet y le asignamos un id Único
        uint betId = 0;
        if (_counterBetId > 0){
            require(bets[_counterBetId].betType != _betType, "Las apuestas son del mismo tipo");
            require(bets[_counterBetId].odd == _odd, "No coinciden las cuotas");
            require(bets[_counterBetId].betStatus == BetStatus.OPEN, "La otra apuesta no está abierta");
            
            betId = _createAndMatch( _marketId
                                   , _runnerId
                                   , _odd
                                   , _betType
                                   , stake
                                   , _counterBetId );
        }
        else{
            betId = _createBet( _marketId
                              , _runnerId
                              , _odd
                              , _betType
                              , stake
                              , 0
                              , BetResult.PENDING
                              , BetStatus.OPEN );
        }
        
        //Agregamos la apuesta al histórico del usuario
        ownerToBetsIndex[msg.sender].push(betId);
        
        //Guardamos al apostador
        betIndexToOwner[betId] = msg.sender;

        //Agregamos la apuesta a la base de Mercados
        betsByMarket[_marketId].push(betId);  
        //Incrementamos el stake acumulado por marcado
        totalStakeByMarket[_marketId] = totalStakeByMarket[_marketId] + stake;
    }

    /**
     * @dev Obtiene la lista de las apuestas matcheadas
     * @param _betId es el ID de la apuesta que se quiere consultar
     */
    function getMatchedBets(uint _betId) public view returns(uint[] memory){
        require(_betId < bets.length, "El id no existe");
        return matchedBets[_betId];
    }    

    /**
     * @dev Crea y matchea una apuesta con una contraapuesta
     * @param _marketId Id en Laurasia
     * @param _runnerId Runner en Laurasia
     * @param _odd cuota. El valor decimal se transforma a uint. Si en al app el apostador ingresa 1.41, acá llega 141
     * @param _betType tipo de apuesta
     * @param _stake El monto que apostó el jugador
     * @param _counterBetId ID de la apuesta contra la que se apuesta. Si es 0, significa que es un nuevo odd
     * @return betId - El ID de la apuesta
     */
    function _createAndMatch( uint _marketId, uint _runnerId, uint _odd, BetType _betType
                            , uint _stake, uint _counterBetId ) internal returns(uint){
        //Obtenemos la contrapauesta
        Bet storage counterBet = bets[_counterBetId];
        
        //Calculamos el total del stake disponible de la contraapuesta
        uint availableCounterStake = counterBet.stake - counterBet.matchedStake;    
        uint betId = 0;

        //Si el stake disponible es 0, tenemos que crear la nueva apuesta como abierta y 
        //sin matchedStake. Debemos cerrar la contraapuesta y no realizar el matcheo de las apuestas
        if (availableCounterStake == 0){
            counterBet.betStatus = BetStatus.CLOSED;
            betId = _createBet( _marketId
                              , _runnerId
                              , _odd
                              , _betType
                              , _stake, 
                              0
                              , BetResult.PENDING
                              , BetStatus.OPEN );
        }
        else{
            //Se repite _createBet en todos los casos por claridad en la lectura del código

            //Caso 1: Las apuestas matchean completamente porque el stake es el mismo. Ambas se deben cerrar,
            //acutalizar el matchedStake y agregar el ID a la lista de matchedBets
            if (_stake == availableCounterStake){
                emit Print("caso1", "Sumo los stakes");
                counterBet.matchedStake += _stake;
                counterBet.betStatus = BetStatus.FULL_MATCHED;
                betId = _createBet( _marketId
                                  , _runnerId
                                  , _odd
                                  , _betType
                                  , _stake
                                  , _stake
                                  , BetResult.PENDING
                                  , BetStatus.FULL_MATCHED);
            }

            //Caso 2: El stake apuesta es superior al disponible de la contrapuesta. Se debe 
            //acualizar el matchedStake y agrgear el ID a la lista de machtedBets de ambas
            //apuestas, pero sólo se debe cerrar la contraApuesta
            else if (_stake > availableCounterStake){
                emit Print("caso 2", "availableCounterStake");
                counterBet.betStatus = BetStatus.FULL_MATCHED;
                counterBet.matchedStake += availableCounterStake;
                betId = _createBet( _marketId
                                  , _runnerId
                                  , _odd
                                  , _betType
                                  , _stake
                                  , availableCounterStake
                                  , BetResult.PENDING
                                  , BetStatus.OPEN );           
            }
            //Caso 3. El stake de la apuesta es inferior al disponible en la contraapuesta. Se debe
            //actualizar el matchedStake de ambos y agregar el ID a la lista de de matched de ambas
            //apuestas, pero sólo se debe cerrar la apuesta.
            else {
                emit Print("caso 3", "_stake");
                counterBet.matchedStake += _stake;
                betId = _createBet( _marketId
                                  , _runnerId
                                  , _odd
                                  , _betType
                                  , _stake
                                  , _stake
                                  , BetResult.PENDING
                                  , BetStatus.FULL_MATCHED );
            }

            //Acá ejecutamos la actaulizacón de las matchedBets
            matchedBets[_counterBetId].push(betId);
            matchedBets[betId].push(_counterBetId);
        }   

        return betId;            
    }

    /**
     * @dev Crea una nueva apuesta y la agrega a la base.
     * @param _marketId Id en Laurasia
     * @param _runnerId Runner en Laurasia
     * @param _odd cuota. El valor decimal se transforma a uint. Si se ingresa 1.41, llega 141
     * @param _betType tipo de apuesta
     * @param _stake El monto apostado por el jugador
     * @param _matchedStake El monto que se matcheo hasta el momento
     * @param _betResult El resultado de la apuesta
     * @param _betStatus El estado de la apuesta
     * @return betId - El ID de la apuesta
     */
    function _createBet( uint _marketId, uint _runnerId, uint _odd
                       , BetType _betType, uint _stake, uint _matchedStake
                       , BetResult _betResult, BetStatus _betStatus) internal returns(uint){
        //Creamos el el Bet y le asignamos un id Único
        uint betId = bets.push( Bet( _marketId
                                   , _runnerId
                                   , _odd
                                   , _stake
                                   , _matchedStake
                                   , _betType
                                   , _betResult
                                   , _betStatus ) ) - 1;

        //Verificamos que no haya bufferOverflow
        require(betId == uint256(uint32(betId)), "Hubo buffer overflow en alta de apuesta");  
        return betId;    
    }
}