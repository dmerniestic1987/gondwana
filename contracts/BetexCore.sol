pragma solidity 0.5.2;
import "./BetexAuthorization.sol";
import "./BetexSettings.sol";

/**
 * @dev BetexCore contiene la lógica para poder colocar apuestas, cobrarrlas y
 * calcular las comisiones para la resolución. 
 */
  //TODO: 08/07/2019 Los seteos críticos deberían hacerse a través de contratos de votación
contract BetexCore is BetexAuthorization {
    BetexSettings public betexSettings;
    
    event P2PBetAccepted( address indexed _bettor, 
                          uint256 _betId, 
                          string _cryptoSymbol );

    event P2PBetCreated( address indexed _bettor, 
                         uint256 _betId, 
                         string _cryptoSymbol );

    event MarketBetPlaced( address indexed _bettor, 
                           uint256 _betId, 
                           bool _matched, 
                           bool _isBack, 
                           string _cryptoSymbol );

    event BetCanceled(address indexed _bettor, uint256 _betId);

    event BetCharged(address indexed _bettor, uint256 _betId);

    /**
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _bettor address del apostador
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack true si la apuesta es a favor, false de lo contrario
     */
    function placeMarketBetBtx(
        address _bettor,
        bytes32 _marketHash, 
        bytes32 _runnerHash, 
        uint256 _odd, 
        uint256 _stake, 
        bool _isBack) external onlyWhitelist() {

        emit MarketBetPlaced(_bettor, block.number, false, _isBack, "BTX");
    }

    /** 
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _bettor address del apostador
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack true si la apuesta es favor, false de lo contrario
    */    
    function placeMarketBetWei(
        address _bettor,
        bytes32 _marketHash, 
        bytes32 _runnerHash, 
        uint256 _odd, 
        uint256 _stake, 
        bool _isBack) external onlyWhitelist() {

        emit MarketBetPlaced(_bettor, block.number, false, _isBack, "WEI");
    }
    
    /**
     * @dev Cancela una apuesta de mercado y se le cobran las comisiones correspondientes
     * @param _bettor address del apostador
     * @param _betId id de la apuesta
     */
    function cancelMarketBet(address _bettor, uint256 _betId) external onlyWhitelist() {
        emit BetCanceled(_bettor, _betId);
    }

    /**
     * @dev Cobra una apuesta ganadora. Tiene asociado un costo de comisión
     * @param _bettor address del apostador
     * @param _betId id de la apuesta
     */
    function chargeMarketBet(address _bettor, uint256 _betId) external onlyWhitelist() {
        emit BetCharged(_bettor, _betId);
    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketHash hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @return (maxBackOdd, maxLayOdd): Cuota máxima a favor y en contra
     */
    function getMaxOdds(bytes32 _marketHash,bytes32 _runnerHash) external view onlyWhitelist() returns(uint256, uint256) {
        return (100, 100);
    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _bettor address del apostador
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _amountWei monto en wei
     */
    function createP2PBetWei(address _bettor, bytes32 _marketHash, bytes32 _runnerHash, uint256 _amountWei) external onlyWhitelist() {
        emit P2PBetCreated( _bettor, block.number, "WEI" );
    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _bettor address del apostador
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _amountBtx monto en Btx
     */
    function createP2PBetBtx(address _bettor, bytes32 _marketHash, bytes32 _runnerHash, uint256 _amountBtx) external onlyWhitelist() {
        emit P2PBetCreated( _bettor, block.number, "BTX" );
    }

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _bettor address del apostador
     * @param _betId id of bet
     * @param _amount monto en BTX
     */
    function acceptP2PBetBtx(address _bettor, uint256 _betId, uint256 _amount) external onlyWhitelist() {
        emit P2PBetAccepted( _bettor, _betId, "BTX");
    }

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _bettor address del apostador
     * @param _betId id of bet
     * @param _amount monto en WEI
     */
    function acceptP2PBetWei(address _bettor, uint256 _betId, uint256 _amount) external onlyWhitelist() {
        emit P2PBetAccepted( _bettor, _betId, "P2P");
    }

    /**
     * @dev Cancela una apuesta P2P(directa) que esté abierta
     * @param _bettor address del apostador
     * @param _betId id of bet
     */
    function cancelP2PBet(address _bettor, uint256 _betId) external onlyWhitelist() {

    }

    /**
     * @dev Rechaza una apuesta P2P(directa) que esté abierta
     * @param _bettor address del apostador
     * @param _betId id of bet
     */
    function refuseP2PBet(address _bettor, uint256 _betId) external onlyWhitelist() {

    }

    /**
     * @dev Cobra una apuesta P2P(directa) que esté abierta
     * @param _bettor address del apostador
     * @param _betId id of bet
     */
    function chargeP2PBet(address _bettor, uint256 _betId) external onlyWhitelist() {

    }    

    function init(address _betexMobileAddress, address _betexSetting ) 
        onInitialize() onlyOwner() public {
        betexSettings = BetexSettings(betexSettings);
        addToWhiteList(_betexMobileAddress);
    }
}