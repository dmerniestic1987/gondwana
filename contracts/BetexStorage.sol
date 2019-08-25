pragma solidity 0.5.10;
import "./BetexAuthorization.sol";
/**
 * @dev  BetexStorage guarda el estado de Betex. Contiene información
 * de las apusetas realizadas y los mercados que se administran con Laurasia
 */
contract BetexStorage is BetexAuthorization {
    enum BetType { BACK, LAY }
    enum BetStatus { OPEN, CLOSED, SUSPENDED, CHARGED }
    enum MarketStatus { OPEN, READY, CLOSED, SUSPENDED, RESOLVED }
    enum EventStatus { OPEN, CLOSED, SUSPENDED }

    struct Market {
        bool doesExist;
        MarketStatus marketStatus;
        uint256 totalRunners;
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
    mapping(bytes32 => bool) private activeMarketRunners;
    Market[] private markets;

    mapping(bytes32 => bool) private winners;
    uint256 private maxRunnersByMarket;
    uint256 private maxMarketsByEvent;
    Bet[] private bets;

    constructor(uint256 _maxRunnersByMarket, uint256 _maxMarketsByEvent) public {
        maxRunnersByMarket = _maxRunnersByMarket;
        maxMarketsByEvent = _maxMarketsByEvent;
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

    /**
    * @dev Verifica que sea un nuevo evento
    */
    modifier eventMustExist(uint256 _eventId){
        uint256 eventIndex = eventsMapping[_eventId];
        require(eventIndex > 0, "Event already exists");
        _;
    }

    /**
    * @dev Verifica que el evento o el mercado no correspondan a los inserts iniciales
    */
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
     * @dev Verfica que el mercado se encuentre en un determinado estado
     * @param _marketId marketId
     * @param _requiredStatus estado requerido
     */
    modifier inMarketStatus(uint256 _marketId, MarketStatus _requiredStatus) {
        require(getMarketStatus(_marketId) == _requiredStatus, "Market status is incorrect");
        _;
    }

    /**
     * @dev Verfica que el evento se encuentre en un determinado estado
     * @param _eventId eventId
     * @param _requiredStatus estado requerido
     */
    modifier inEventStatus(uint256 _eventId, EventStatus _requiredStatus) {
        require(getEventStatus(_eventId) == _requiredStatus, "Event status is incorrect");
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
    * @dev Verifica que sea un nuevo mercado
    */
    modifier activeMarketRunner(bytes32 _marketRunnerHash){
        require(activeMarketRunners[_marketRunnerHash], "Market Runner does not exist");
        _;
    }

    /**
     * @dev Verifica que la dirección no venga vacía
     */
    modifier notEmptyRunnerHash(bytes32 _address){
        require(_address != 0x0, "Empty runner hash");
        _;
    }
    /**
     * @dev Suspende un evento determinado
     * @param _eventId eventId
     */
    function suspendEvent(uint256 _eventId) external onlyWhitelist() inEventStatus(_eventId, EventStatus.OPEN){
        uint256 eventIndex = eventsMapping[_eventId];
        events[eventIndex].eventStatus = EventStatus.SUSPENDED;
    }

    /**
     * @dev Cierra un evento determinado
     * @param _eventId eventId
     */
    function closeEvent(uint256 _eventId) external onlyWhitelist() inEventStatus(_eventId, EventStatus.OPEN){
        uint256 eventIndex = eventsMapping[_eventId];
        events[eventIndex].eventStatus = EventStatus.CLOSED;
    }
    
    /**
     * @dev Abre un mercado determinado con n competidores o runners. Por control interno.
     * @param _eventId Id el evento de Laurasia
     * @param _marketId Id del mercado de Laurasia
     * @param _runnerHashes totalRunners
     */
    function openMarketWithRunners( uint256 _eventId, uint256 _marketId, bytes32[] calldata _runnerHashes)
    external noGenesis(_eventId, _marketId) onlyWhitelist() isNewMarket(_marketId) {
        require(_runnerHashes.length <= maxRunnersByMarket, "Too many runners");
        uint256 eventIndex = eventsMapping[_eventId];
        if (eventIndex == 0){
            eventIndex = events.push(MarketEvent(true, EventStatus.OPEN)) - 1;
            eventsMapping[_eventId] = eventIndex;
        }
        uint256 marketIndex = markets.push(Market(true, MarketStatus.READY, _runnerHashes.length)) - 1;
        marketsMapping[_marketId] = marketIndex;
        marketRunnerHashes[marketIndex] = _runnerHashes;
    }

    /**
     * @dev Abre un mercado determinado con n competidores o runners. Por control interno.
     * @param _eventId Id el evento de Laurasia
     * @param _marketId Id del mercado de Laurasia
     * @param _totalRunners total de competidores en el mercado
     */
    function openMarket( uint256 _eventId, uint256 _marketId, uint256 _totalRunners)
    external noGenesis(_eventId, _marketId) onlyWhitelist() isNewMarket(_marketId) {
        require(_totalRunners <= maxRunnersByMarket, "Too many runners");
        uint256 eventIndex = eventsMapping[_eventId];
        if (eventIndex == 0){
            eventIndex = events.push(MarketEvent(true, EventStatus.OPEN)) - 1;
            eventsMapping[_eventId] = eventIndex;
        }
        uint256 marketIndex = markets.push(Market(true, MarketStatus.OPEN, _totalRunners)) - 1;
        marketsMapping[_marketId] = marketIndex;
    }

    /**
     * @dev Agrega un runner a un market determinado
     * @param _marketId ID del mercado de Laurasia
     * @param _marketRunnerHash hash del mercado
     */
    function addMarketRunner( uint256 _marketId, bytes32 _marketRunnerHash)
    external onlyWhitelist() inMarketStatus(_marketId, MarketStatus.OPEN) notEmptyRunnerHash(_marketRunnerHash){
        uint256 marketIndex = marketsMapping[_marketId];
        Market memory market = markets[marketIndex];
        require(marketRunnerHashes[marketIndex].length < market.totalRunners, "Adding too many runners");
        require(!activeMarketRunners[_marketRunnerHash], "Runner already exists");
        marketRunnerHashes[marketIndex].push(_marketRunnerHash);
        activeMarketRunners[_marketRunnerHash] = true;
        if (marketRunnerHashes[marketIndex].length == market.totalRunners){
            markets[marketIndex].marketStatus = MarketStatus.READY;
        }
    }

    /**
     * @dev Resuelve un mercado determinado
     * @param _marketId marketId
     * @param _winnerMarketRunner hash del ganador del mercado
     */
    function resolveMarket(uint256 _marketId, bytes32 _winnerMarketRunner) external
    onlyWhitelist() notEmptyRunnerHash(_winnerMarketRunner)
    activeMarketRunner(_winnerMarketRunner) {
        uint256 marketIndex = marketsMapping[_marketId];
        bool isReadyOrClosed = (markets[marketIndex].marketStatus == MarketStatus.READY || 
                                markets[marketIndex].marketStatus == MarketStatus.CLOSED);
        require(isReadyOrClosed, "Market in incorrect status");
        markets[marketIndex].marketStatus = MarketStatus.RESOLVED;
        winners[_winnerMarketRunner] = true;
    }

    /**
     * @dev Cierra un mercado determinado. Signfica que ya no se pueden aceptar más apuestas
     * y se está esperando el resultado del evento deportivo. Tipicamente los eventos de MMA o
     * Boxeo solo aceptarán apuestas hasta antes que comience el combate.
     * @param _marketId marketId
     */
    function closeMarket(uint256 _marketId) external
    onlyWhitelist() inMarketStatus(_marketId, MarketStatus.READY) {
        uint256 marketIndex = marketsMapping[_marketId];
        markets[marketIndex].marketStatus = MarketStatus.CLOSED;
    }


    /**
     * @dev Resuelve un mercado determinado
     * @param _marketId marketId
     */
    function suspendMarket(uint256 _marketId) external onlyWhitelist() marketMustExist(_marketId) {
        uint256 marketIndex = marketsMapping[_marketId];
        require(markets[marketIndex].marketStatus != MarketStatus.CLOSED, "Market is closed");
        markets[marketIndex].marketStatus = MarketStatus.SUSPENDED;
    }

    /**
     * @dev Verificia que un runner de un mercado determinado exista en la plataforma
     * @param _marketRunnerHash hash
     */
    function isActiveMarketRunner(bytes32 _marketRunnerHash) public view notEmptyRunnerHash(_marketRunnerHash) returns(bool) {
        return activeMarketRunners[_marketRunnerHash];
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
     * @dev Verifica si una competidor es el ganador de un mercado determinado.
     * @param _marketRunnerHash hash del mercado
     * @return true si es ganador, false de contrario
     */
    function isWinner(bytes32 _marketRunnerHash) public view notEmptyRunnerHash(_marketRunnerHash) returns(bool) {
        return winners[_marketRunnerHash];
    }

    /**
     * @dev obtiene el estado de un mercado
     * @param _marketId marketId
     */
    function getMarketStatus(uint256 _marketId) public marketMustExist(_marketId) view  returns(MarketStatus) {
        uint256 marketIndex = marketsMapping[_marketId];
        return markets[marketIndex].marketStatus;
    }

    /**
     * @dev obtiene el estado de un evento determinado
     * @param _eventId eventId
     */
    function getEventStatus(uint256 _eventId) public eventMustExist(_eventId) view returns (EventStatus) {
        uint256 eventIndex = eventsMapping[_eventId];
        return events[eventIndex].eventStatus;
    }

    /**
     * @dev Inicializa el contrato
     * @param _betexCoreAddress Address del proxy de Betex Laurasia
     * @param _betexLaurasiaAddress Address de Betex Core
     */
    function init(address _betexCoreAddress, address _betexLaurasiaAddress ) 
        onInitialize() onlyOwner() public {
        addToWhiteList(_betexCoreAddress);
        addToWhiteList(_betexLaurasiaAddress);
    }
    /**
     * @dev Inicializa las estructuras de datos
     */
    function _genesis() private {
        uint256 GENESIS_INDEX = 0;
        events.push(MarketEvent(true, EventStatus.SUSPENDED));
        eventsMapping[GENESIS_INDEX] = GENESIS_INDEX;
        markets.push(Market(true, MarketStatus.CLOSED,0));
        marketsMapping[GENESIS_INDEX] = GENESIS_INDEX;
        bytes32 runner = keccak256(abi.encodePacked(GENESIS_INDEX, "Betex"));
        marketRunnerHashes[GENESIS_INDEX].push(runner);
        activeMarketRunners[runner] = true;
    }
}