pragma solidity 0.5.2;

import "./BetexAuthorization.sol";

/**
 * @dev  BetexStorage guarda el estado de Betex.
 */
contract BetexStorage is BetexAuthorization {
    enum BetType { BACK, LAY }
    enum BetStatus { OPEN, CLOSED, SUSPENDED, CHARGED }
    enum MarketStatus { OPEN, CLOSED, SUSPENDED }
    enum EventStatus { OPEN, CLOSED, SUSPENDED }

    struct Market {
        bool doesExist;
        MarketStatus marketStatus;
        bytes32[] runnerHashes;
    }

    struct Event {
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

    mapping(uint256 => Event) private events;
    mapping(uint256 => Market) private markets;
    mapping(bytes32 => bool) private winners;
    uint256 private maxRunnersByMarket;
    Bet[] private bets;

    constructor(uint256 _maxRunnersByMarket) public {
        maxRunnersByMarket = _maxRunnersByMarket;
    }
    /**
    * @dev Verifica que sea un nuevo evento
    */
    modifier isNewEvent(uint256 _eventId){
        require(!events[_eventId].doesExist, "Event already exists");
        _;
    }

    /**
    * @dev Verifica que sea un nuevo mercado
    */
    modifier newMarket(uint256 _marketId){
        require(!markets[_marketId].doesExist, "Market already exists");
        _;
    }

    /**
    * @dev Verifica que sea un nuevo mercado
    */
    modifier activeOpenMarket(uint256 _marketId){
        require(!markets[_marketId].doesExist, "Market already exists");
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
     * @param _marketRunnerHashes Array con los Hashes de los competidores por market. Máximo 3 elementos de sha3 (marketId + runnerId)
     */
    function openMarket( uint256 _eventId, uint256 _marketId, bytes32[] calldata _marketRunnerHashes)
    external isNewEvent(_eventId) newMarket(_marketId) {
        require(_marketRunnerHashes.length <= maxRunnersByMarket, "There are too much runners");
        events[_eventId] = Event(true, EventStatus.OPEN);
        markets[_marketId] = Market(true, MarketStatus.OPEN, _marketRunnerHashes);
    }

    /**
     * @dev Verifica si un mercado existe
     * @param _marketId marketId
     * @return true si existe, false de lo contrario
     */
    function doesMarketExists(uint256 _marketId) public view returns(bool){
        return markets[_marketId].doesExist;
    }
    /**
     * @dev Obtiene los market runners con el ID de mercado
     * @param _marketId marketId
     * @return _marketRunnerHashes bytes32[]
     */
    function getMarketRunners(uint256 _marketId) public view returns(bytes32[] memory _marketRunnerHashes) {
        return markets[_marketId].runnerHashes;
    }
}