pragma solidity 0.5.2;

import "./IBetexMobileGondwana.sol";
import "./BetexAuthorization.sol";
import "./BetexSettings.sol";

/**
 * @dev Este contrato es el Proxy con el que el usuario de la aplicación 
 * móvil puede comunicarse con la plataforma Betex. 
 */
contract BetexMobileGondwana is IBetexMobileGondwana, BetexAuthorization {
    BetexSettings private betexSettings;
    
   /**
     * @dev Verifica si el sistema está pausado.
     * @return true si está parado, false de lo contrario
     */
    function isPaused() external view returns(bool) {
        return false;
    }

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
     * @dev El usuario se autoexcluye de la plataforma.
     */
    function selfExclude() external {

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
    function createP2PBetWei(bytes32 _marketRunnerHash, uint256 _amountWei) external {

    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash hashId
     * @param _amountBtx monto en Btx
     */
    function createP2PBetBtx(bytes32 _marketRunnerHash, uint256 _amountBtx) external {

    }

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     * @param _amountWei hashId
     */
    function acceptP2PBet(uint256 _betId, uint256 _amountWei) external {

    }

    function cancelP2PBet(uint256 _betId) external {

    }

    function refuseP2PBet(uint256 _betId) external {

    }

    function chargeP2PBet(uint256 _betId) external {

    }    

    function init(address _betexSettings) onInitialize() onlyOwner() public {
        betexSettings = BetexSettings(_betexSettings);
    }
}