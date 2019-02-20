pragma solidity >= 0.5.0;
import "./BetexAdmin.sol";

contract BetexBase is BetexAdmin{
    event Print(string name, string info);
    event PlacedBet(address bettor, uint128 marketId, uint betId, uint64 odds, uint stake);

    enum BetType        { BACK, LAY }                                       
    enum BetStatus      { OPEN, FULL_MATCHED, CLOSED }   

    struct Bet{
        uint128 marketId;       //Clave del mercado. Se calcula: keccak256(marketId + Fecha Evento) 
        uint64  runnerId;       //Runner por el que se apuesta        
        uint64  odd;            //Es la cuota. El sistema sólo permite 2 decimal,
                                //como entereo. Por ejemplo 2,73 se guarda como 273. 
        uint stake;             //Es el monto apostado en WEI. Debe coincidir con msg.sender en la creación        
        uint matchedStake;      //Es la cantidad de diner que hasta el momento se pudo matchear contra otras apuestas. 
                                //Si stake == matchedStake significa que la apuesta quedó en OPEN_MATCHED
        BetType betType;        //Tipo de apuesta. Back: A favor, Lay: En contra
        BetStatus betStatus;    //Estado de la apuesta 
    }

    //Guarda las apuestas con ID único  
    Bet[] public bets;         
    
    mapping(uint => uint[]) public matchedBets ;

    //Agrupa las apuestas por tipo de Mercado.  //Key: MarketId  //Value: Id - array índices de bets
    mapping(uint128 => uint[]) public betsByMarket; 

    //Permite obtener los indices de todas las puestas de una dirección en particular
    mapping(address => uint[]) private ownerToBetsIndex; 
                                                         
    //Permite determinar al  emisor de una apuesta
    mapping(uint => address payable) private betIndexToOwner;                                          

    //Permite conocer cual fue el resultado de un mercado dado el ID de mercado y el runner
    mapping(bytes32 => bool) private marketResultWinners;

    constructor() public {
        owner = msg.sender;
        marketManagerAddress = msg.sender;
        cfoAddress  = msg.sender;
        minimumStake = 0.01 ether;
        commission = 5; //Se cobra el 5% de comisión al ganador
        //Creamos el mercado y la apuesta génesis
        addMarket(0);
        _createBet( 0, 0, 1, BetType.BACK, 0, 0, BetStatus.CLOSED); 
    }

    function resolveMarket( uint128 _marketId, uint64 _winnerRunnerId
                          , uint64[] memory _loosersRunnersId ) public onlyMarketManager(){
        
        require( _loosersRunnersId.length > 0 && _loosersRunnersId.length <= 50
               , "Tienen que haber al menos 1 Runner y menos de 50");
        
        //El mercado tiene que existir
        require(marketsExists[_marketId], "El mercado no existe");

        _saveBetWinners(_marketId, _winnerRunnerId, _loosersRunnersId);
    }

    /**
     * Determina si ganó alguna de las apuestas
     */
    function isBetWinner(uint betId) public view returns(bool){
        require(betId < bets.length, "El ID ingresado no existe");
        require(betIndexToOwner[betId] == msg.sender, "Usted no apostó");
        Bet memory bet = bets[betId];
        bytes32 marketResultKey = keccak256(abi.encodePacked(bet.marketId, bet.runnerId, bet.betType));
        return marketResultWinners[marketResultKey];
    }

    /**
     * @dev Registra una nueva apuesta para un mercado y un runner determinado
     * @param _marketId Id en Laurasia
     * @param _runnerId Runner en Laurasia
     * @param _odd cuota. El valor decimal se transforma a uint. Si en al app el apostador ingresa 1.41, acá llega 141
     * @param _betType tipo de apuesta
     * @param _counterBetId ID de la apuesta contra la que se apuesta. Si es 0, significa que es un nuevo odd
     */
    function placeBet( uint128 _marketId, uint64 _runnerId, uint64 _odd
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
                              , BetStatus.OPEN );
        }
        
        //Agregamos la apuesta al histórico del usuario
        ownerToBetsIndex[msg.sender].push(betId);
        
        //Guardamos al apostador
        betIndexToOwner[betId] = msg.sender;

        //Agregamos la apuesta a la base de Mercados
        betsByMarket[_marketId].push(betId);  
        
        //Emitimos la orden
        emit PlacedBet(msg.sender, _marketId, betId, _odd, stake);
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
    function _createAndMatch( uint128 _marketId, uint64 _runnerId, uint64 _odd, BetType _betType
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
                              , BetStatus.OPEN );
        }
        else{
            //Se repite _createBet en todos los casos por claridad en la lectura del código

            //Caso 1: Las apuestas matchean completamente porque el stake es el mismo. Ambas se deben cerrar,
            //acutalizar el matchedStake y agregar el ID a la lista de matchedBets
            if (_stake == availableCounterStake){
                counterBet.matchedStake += _stake;
                counterBet.betStatus = BetStatus.FULL_MATCHED;
                betId = _createBet( _marketId
                                  , _runnerId
                                  , _odd
                                  , _betType
                                  , _stake
                                  , _stake
                                  , BetStatus.FULL_MATCHED);
            }

            //Caso 2: El stake apuesta es superior al disponible de la contrapuesta. Se debe 
            //acualizar el matchedStake y agrgear el ID a la lista de machtedBets de ambas
            //apuestas, pero sólo se debe cerrar la contraApuesta
            else if (_stake > availableCounterStake){
                counterBet.betStatus = BetStatus.FULL_MATCHED;
                counterBet.matchedStake += availableCounterStake;
                betId = _createBet( _marketId
                                  , _runnerId
                                  , _odd
                                  , _betType
                                  , _stake
                                  , availableCounterStake
                                  , BetStatus.OPEN );           
            }
            //Caso 3. El stake de la apuesta es inferior al disponible en la contraapuesta. Se debe
            //actualizar el matchedStake de ambos y agregar el ID a la lista de de matched de ambas
            //apuestas, pero sólo se debe cerrar la apuesta.
            else {
                counterBet.matchedStake += _stake;
                betId = _createBet( _marketId
                                  , _runnerId
                                  , _odd
                                  , _betType
                                  , _stake
                                  , _stake
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
     * @param _betStatus El estado de la apuesta
     * @return betId - El ID de la apuesta
     */
    function _createBet( uint128 _marketId, uint64 _runnerId, uint64 _odd
                       , BetType _betType, uint _stake, uint _matchedStake
                       , BetStatus _betStatus) internal returns(uint){
        //Creamos el el Bet y le asignamos un id Único
        uint betId = bets.push( Bet( _marketId
                                   , _runnerId
                                   , _odd
                                   , _stake
                                   , _matchedStake
                                   , _betType
                                   , _betStatus ) ) - 1;

        //Verificamos que no haya más de 2^128 apuestas
        require(betId == uint256(uint64(betId)), "Hubo buffer overflow en alta de apuesta");  
        return betId;    
    }

    /**
     * @dev Obtiene el resultado de una apuesta determinada
     * @param _marketId Id del mercado Laurasia
     * @param _winnerRunnerId Id del Runner Ganador en Laurasia
     * @param _loosersRunnersId Id de los perdedores en Laurasia
     */
    function _saveBetWinners( uint128 _marketId, uint64 _winnerRunnerId
                            , uint64[] memory _loosersRunnersId ) internal{
        //Marcamos a los ganadores: Los que apostaron a favor de un mercado y un runner particular
        bytes32 marketResultKey = keccak256(abi.encodePacked(_marketId, _winnerRunnerId, BetType.BACK));
        marketResultWinners[marketResultKey] = true;
        
        //Marcamos a los perdedores: Los que apostaron en contra de un mercado particular
        for (uint8 i = 0; i < _loosersRunnersId.length; i++){
            marketResultKey = keccak256(abi.encodePacked(_marketId, _loosersRunnersId[i], BetType.LAY));
            marketResultWinners[marketResultKey] = true;
        }
    }    
}