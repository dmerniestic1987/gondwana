pragma solidity 0.5.2;

import "./BetexAuthorization.sol";

/**
 * @dev  BetexStorage guarda el estado de Betex.
 */
contract BetexStorage is BetexAuthorization {
    enum BetType { BACK, LAY }
    enum BetStatus { OPEN, CLOSED, SUSPENDED, CHARGED }
    enum MarketStatus { OPEN, CLOSED, SUSPENDED, RESOLVED }
    enum EventStatus { OPEN, CLOSED, SUSPENDED, RESOLVED }

    struct Market {
        bool doesExist;
        MarketStatus marketStatus;
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
    Bet[] private bets;  

    /**
     * @dev Verifica si una competidor es el ganador de un mercado determinado.
     * @param _marketRunnerHash hash del mercado
     * @return true si es ganador, false de contrario
     */
    function isWinner(bytes32 _marketRunnerHash) public view returns(bool) {
        return winners[_marketRunnerHash];
    }
    
}