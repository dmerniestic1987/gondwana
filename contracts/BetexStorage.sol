pragma solidity 0.5.10;

/**
 * @dev  BetexStorage guarda el estado de Betex.
 */
contract BetexStorage {
 enum BetType { BACK, LAY }
    enum BetStatus { OPEN, CLOSED, SUSPENDED, CHARGED }
    enum MarketStatus { OPEN, CLOSED, SUSPENDED }
    enum EventStatus { OPEN, CLOSED, SUSPENDED }
    event Test(string key, string description);

    struct Market {
        bool doesExist;
        MarketStatus marketStatus;
    }

    struct MarketEvent {
        bool doesExist;
        EventStatus eventStatus;
    }
    
    struct Bet {
        bool isMarketBet;           //True si la apuesta es de mercado, false si es P2P
        bytes32 marketRunnerHash;   //Clave del mercado y la apuesta
        bytes32 cryptoSymbol;       //Simbolo de la apuesta. WEI o BTX por el momento
        uint256 odd;                //Es la cuota. El sistema sólo permite 2 decimal. Si es 2,73, guardo como 273.
        uint256 stake;              //Es el monto apostado en WEI. Para BACK debe coincidir con msg.value
        uint256 matchedStake;       //Es la cantidad de diner que hasta el momento se pudo matchear contra otras apuestas.
                                    //Si stake == matchedStake significa que la apuesta quedó en OPEN_MATCHED
        BetType betType;            //Tipo de apuesta. Back: A favor, Lay: En contra
        BetStatus betStatus;        //Estado de la apuesta a
    }

    mapping(uint256 => uint256) private eventsMapping;
    MarketEvent[] private events;

    mapping(uint256 => uint256) private marketsMapping;
    mapping(uint256 => bytes32[]) private marketRunnerHashes;
    mapping(bytes32 => bool) private marketRunnerHashesDupControl;
    Market[] private markets;

    mapping(bytes32 => bool) private winners;
    uint256 private maxRunnersByMarket;
    Bet[] private bets;

    constructor(uint256 _maxRunnersByMarket) public {
        maxRunnersByMarket = _maxRunnersByMarket;
        _genesis();
    }
    /**
    * @dev Verifica que sea un nuevo evento
    */
    modifier isNewEvent(uint256 _eventId){
        uint256 eventIndex = eventsMapping[_eventId];
        require(eventIndex == 0, "Event already exists");
        _;
    }
    
    modifier noGenesis(uint256 _eventId, uint256 _marketId) {
        require(_eventId > 0, "Event does not exists");
        require(_marketId > 0, "Market does not exists");
        _;
    }
    
    /**
    * @dev Verifica que sea un nuevo mercado
    */
    modifier isNewMarket(uint256 _marketId){
        uint256 marketIndex = marketsMapping[_marketId];
        require(marketIndex == 0, "Market already exists");
        _;
    }

    /**
    * @dev Verifica que sea un nuevo mercado
    */
    modifier marketMustExist(uint256 _marketId){
        require(doesMarketExists(_marketId), "Market does not exist");
        _;
    }


    /**
     * @dev Verifica si una competidor es el ganador de un mercado determinado.
     * @param _marketRunnerHash hash del mercado
     * @return true si es ganador, false de contrario
     */
    function isWinner(bytes32 _marketRunnerHash) public view returns(bool) {
        return winners[_marketRunnerHash];
    }

    /**
     * @dev Abre un mercado determinado con n competidores o runners. Por control interno.
     * @param _eventId Id el evento de Laurasia
     * @param _marketId ID del mercado de Laurasia
     */
    function openMarket( uint256 _eventId, uint256 _marketId)
    external noGenesis(_eventId, _marketId) isNewMarket(_marketId) {
        uint256 eventIndex = eventsMapping[_eventId];
        if (eventIndex == 0){
            eventIndex = events.push(MarketEvent(true, EventStatus.OPEN)) - 1;
            eventsMapping[_eventId] = eventIndex;
        }
        uint256 marketIndex = markets.push(Market(true, MarketStatus.OPEN)) - 1;
        marketsMapping[_marketId] = marketIndex;
        emit Test("openMarket", "Evento creado");
    }

    /**
     * @dev Agrega un runner a un market determinado
     * @param _marketId ID del mercado de Laurasia
     * @param _marketRunnerHash hash del mercado
     */
    function addMarketRunner( uint256 _marketId, bytes32 _marketRunnerHash) external marketMustExist(_marketId){
        uint256 marketIndex = marketsMapping[_marketId];
        require(marketRunnerHashes[marketIndex].length < maxRunnersByMarket, "There are too many runners");
        require(!marketRunnerHashesDupControl[_marketRunnerHash], "Runner already exists");
        marketRunnerHashes[marketIndex].push(_marketRunnerHash);
        marketRunnerHashesDupControl[_marketRunnerHash] = true;
        emit Test("addMarketRunner", "Runner agregado");
    }

    /**
     * @dev Verifica si un mercado existe
     * @param _marketId marketId
     * @return b true si existe, false de lo contrario
     */
    function doesMarketExists(uint256 _marketId) public view returns(bool){
        if (_marketId == 0){
            return false;
        }
        uint256 marketIndex = marketsMapping[_marketId];
        if (marketIndex == 0) {
            return false;
        }
        
        Market memory market = markets[marketIndex];
        return market.doesExist;
    }
    /**
     * @dev Obtiene los market runners con el ID de mercado
     * @param _marketId marketId
     * @return _marketRunnerHashes bytes32[]
     */
    function getMarketRunners(uint256 _marketId) public marketMustExist(_marketId) view returns(bytes32[] memory){
        require(_marketId > 0, "Market does not exists");
        uint256 marketIndex = marketsMapping[_marketId];
        require(marketIndex > 0, "Market runners does not exists");
        return marketRunnerHashes[marketIndex];
    }

    /**
     * @dev Inicializa las estructuras de datos
     */
    function _genesis() private {
        events.push(MarketEvent(true, EventStatus.CLOSED));
        eventsMapping[0] = 0;
        markets.push(Market(true, MarketStatus.CLOSED));
        marketsMapping[0] = 0;
        bytes32 runner = keccak256(abi.encodePacked("Betex"));
        marketRunnerHashes[0].push(runner);
        marketRunnerHashesDupControl[runner] = true;
    }
}