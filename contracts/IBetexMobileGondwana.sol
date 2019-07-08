pragma solidity 0.5.2;

/**
 * @dev Es la interfaz entre BetexMobile y Gondwana. Define las funciones
 * para realizar apuestas de mercado y P2P.
 */
interface IBetexMobileGondwana {
    /**
     * @dev Verifica si el sistema está pausado.
     * @return true si está parado, false de lo contrario
     */
    function isPaused() external view returns(bool);

    /**
     * @dev Guarda la configuración del usuario determinado
     * @param _amountWeiPerDay máxima cantidad de apuestas de wei por día
     * @param _amountBtxPerDay máxima cantidad de apuestas de btx por día
     * @param _maxBetsPerDay máxima cantidad de apuestas por día
     */
    function saveUserSettings(uint256 _amountWeiPerDay, uint256 _amountBtxPerDay, uint256 _maxBetsPerDay) external;
    
    /**
     * @dev Obtiene la configuración del usuario determinado
     * @return amountWeiPerDay máxima cantidad de apuestas de wei por día
     * @return amountBtxPerDay máxima cantidad de apuestas de btx por día
     * @return maxBetsPerDay máxima cantidad de apuestas por día
     */
    function getUserSettings() external view returns(uint256, uint256, uint256);
    
    /**
     * @dev El usuario se autoexcluye de la plataforma.
     * @return true si está autoexcluido
     */
    function isSelfExcluded() external view returns(bool);

    /**
     * @dev Cancela una apuesta de mercado. Tiene asociado un costo de comisión
     * @param _betId id of bet
     */
    function cancelMarketBet(uint256 _betId) external;

    /**
     * @dev Cobra una apuesta ganadora. Tiene asociado un costo de comisión
     * @param _betId id of bet
     */
    function chargeMarketBet(uint256 _betId) external;

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash hashId
     * @return (maxBackOdd, maxLayOdd): Cuota máxima a favor y en contra
     */
    function getMaxOdds(bytes32 _marketRunnerHash) external view returns(uint256, uint256);

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash sha3(eventId, marketId, runnerId)
     * @param _amountWei monto en wei
     */
    function createP2PBetWei(bytes32 _marketRunnerHash, uint256 _amountWei) external;

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash hashId
     * @param _amountBtx monto en Btx
     */
    function createP2PBetBtx(bytes32 _marketRunnerHash, uint256 _amountBtx) external;

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     * @param _amountWei hashId
     */
    function acceptP2PBet(uint256 _betId, uint256 _amountWei) external;

    /**
     * @dev Cancela una apuesta P2P(directa) que esté abierta. Se cobra una comisión.
     * @param _betId id of bet
     */
    function cancelP2PBet(uint256 _betId) external;

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     */
    function refuseP2PBet(uint256 _betId) external;

    /**
     * @dev Cobra una apuesta P2P(directa) que esté cerrada y ganada
     * @param _betId id de apueta
     */
    function chargeP2PBet(uint256 _betId) external;
}