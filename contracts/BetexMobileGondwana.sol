pragma solidity 0.5.2;

import "./IBetexMobileGondwana.sol";
import "./BetexAuthorization.sol";
import "./BetexSettings.sol";
import "./BetexSelfExcluded.sol";

/**
 * @dev Este contrato es el Proxy con el que el usuario de la aplicación 
 * móvil puede comunicarse con la plataforma Betex. 
 */
contract BetexMobileGondwana is IBetexMobileGondwana, BetexAuthorization {
    BetexSettings private betexSettings;
    BetexSelfExcluded private betexSelfExcluded;

    /**
     * @dev Sólo puede ser initializado una vez
     */
    modifier notSelfExcluded(address better) {
        require(!betexSelfExcluded.isSelfExcluded(better), "Self excluded better");
        _;
    }

   /**
     * @dev Verifica si el sistema está pausado.
     * @return true si está parado, false de lo contrario
     */
    function isPaused() external view returns(bool) {
        return false;
    }

    /**
     * @dev Guarda la configuración del usuario determinado
     * @param _amountWeiPerDay máxima cantidad de apuestas de wei por día
     * @param _amountBtxPerDay máxima cantidad de apuestas de btx por día
     * @param _maxBetsPerDay máxima cantidad de apuestas por día
     */
    function saveUserSettings(
        uint256 _amountWeiPerDay,
        uint256 _amountBtxPerDay, 
        uint256 _maxBetsPerDay) external {
        betexSettings.saveUserSettings(
            msg.sender,
            _amountWeiPerDay,
            _amountBtxPerDay,
            _maxBetsPerDay);      
    }

    /**
     * @dev Obtiene la configuración del usuario determinado
     * @return amountWeiPerDay máxima cantidad de apuestas de wei por día
     * @return amountBtxPerDay máxima cantidad de apuestas de btx por día
     * @return maxBetsPerDay máxima cantidad de apuestas por día
     */
    function getUserSettings() external view returns(uint256, uint256, uint256) {
        return betexSettings.getUserSettings(msg.sender);
    }

    /**
     * @dev El usuario se autoexcluye de la plataforma.
     * @return true si está autoexcluído, false de lo contrario
     */
    function isSelfExcluded() external view returns(bool) {
        return betexSelfExcluded.isSelfExcluded(msg.sender);
    }

    /**
     * @dev Cancela una apuesta de mercado. Tiene asociado un costo de comisión
     * @param _betId id of bet
     */
    function cancelMarketBet(uint256 _betId) external {

    }

    /**
     * @dev Cobra una apuesta ganadora. Tiene asociado un costo de comisión
     * @param _betId id of bet
     */
    function chargeMarketBet(uint256 _betId) external {

    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash hashId
     * @return (maxBackOdd, maxLayOdd): Cuota máxima a favor y en contra
     */
    function getMaxOdds(bytes32 _marketRunnerHash) external view returns(uint256, uint256) {
        return (100, 100);
    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash sha3(eventId, marketId, runnerId)
     * @param _amountWei monto en wei
     */
    function createP2PBetWei(bytes32 _marketRunnerHash, uint256 _amountWei) external notSelfExcluded(msg.sender) {

    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash hashId
     * @param _amountBtx monto en Btx
     */
    function createP2PBetBtx(bytes32 _marketRunnerHash, uint256 _amountBtx) external notSelfExcluded(msg.sender) {

    }

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     * @param _amountWei hashId
     */
    function acceptP2PBet(uint256 _betId, uint256 _amountWei) external notSelfExcluded(msg.sender) {

    }

    function cancelP2PBet(uint256 _betId) external {

    }

    function refuseP2PBet(uint256 _betId) external {

    }

    function chargeP2PBet(uint256 _betId) external {

    }    

    function init(address _betexSettings, address _betexSelfExcluded) onInitialize() onlyOwner() public {
        betexSettings = BetexSettings(_betexSettings);
        betexSelfExcluded = BetexSelfExcluded(_betexSelfExcluded);
    }
}