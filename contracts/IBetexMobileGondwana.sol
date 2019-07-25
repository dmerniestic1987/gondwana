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
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack true si la apuesta es a favor, false de lo contrario
     */
    function placeMarketBetBtx(bytes32 _marketHash, bytes32 _runnerHash, uint256 _odd, uint256 _stake, bool _isBack) external;

    /** 
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack ture si la apuesta es favor, false de lo contrario
    */    
    function placeMarketBetWei(bytes32 _marketHash, bytes32 _runnerHash, uint256 _odd, uint256 _stake, bool _isBack) external payable;

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
     * @param _marketHash hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @return (maxBackOdd, maxLayOdd): Cuota máxima a favor y en contra
     */
    function getMaxOdds(bytes32 _marketHash, bytes32 _runnerHash) external view returns(uint256, uint256);

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketHash hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     */
    function createP2PBetWei(bytes32 _marketHash, bytes32 _runnerHash) external payable;

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketHash hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _amountBtx monto en Btx
     */
    function createP2PBetBtx(bytes32 _marketHash, bytes32 _runnerHash, uint256 _amountBtx) external;

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     * @param _amount hashId
     */
    function acceptP2PBetBtx(uint256 _betId, uint256 _amount) external;

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     */
    function acceptP2PBetWei(uint256 _betId) external payable;

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
    
    /**
     * @dev verifica si una apuesta fue ganadora
     * @param _betId id de apuesta
     * @return true si ganó, false de lo contrario
     */
    function isWinner(uint256 _betId) external view returns (bool);

    /**
     * @dev Devuelve la cantidad máxima por defaul que los usuarios pueden apostar al día.
     * El usuario puede guardar su propia configuración
     * @return defaultMaxAmountWeiPerDay
     */
    function getDefaultMaxAmountWeiPerDay() external returns (uint256);


    /**
     * @dev Devuelve la cantidad máxima por defaul que los usuarios puede apostar al día.
     * El usuario puede guardar su propia configuración
     * @return defaultMaxAmountBtxPerDay expresado en btx
     */
    function getDefaultMaxAmountBtxPerDay() external returns (uint256);

    /**
     * @dev Devuelve la cantidad máxima de apuestas per cápitla que los 
     * usuarios pueden hacer al día. El usuario puede guardar su propia configuración
     * @return defaultMaxBetsPerDay cantidad
     */
    function getDefaultMaxBetsPerDay() external returns (uint256);

    /**
     @dev Devuelve el monto mínimo de apuestas permitadas en BTX.
     @return minStakeBtx
     */
    function getMinStakeBtx() external view returns(uint256);

    /**
     @dev Devuelve el monto máximo de apuestas permitadas en BTX.
     @return maxStakeBtx
     */
    function getMaxStakeBtx() external view returns(uint256);

    /**
     @dev Devuelve el monto mínimo de apuestas permitadas en wei.
     @return minStakeWei
     */
    function getMinStakeWei() external view returns(uint256);

    /**
     @dev Devuelve el monto máximo de apuestas permitadas en wei.
     @return maxStakeWei
     */
    function getMaxStakeWei() external view returns(uint256);

    /**
     @dev Devuelve la información de las comisiones de los ganadores de apuestas en wei.
     @return comissionWinnerBetWei
     */
    function getComissionWinnerBetWei() external view returns(uint256);

    /**
     @dev Devuelve la información de las comisiones por cancelación de apuetas en wei.
     @return comissionCancelBetWei
     */
    function getComissionCancelBetWei() external view returns(uint256);

    /**
     @dev Devuelve la información de las comisiones a los ganadores en btx.
     @return comissionWinnerBetBtx
     */
    function getComissionWinnerBetBtx() external view returns(uint256);

    /**
     @dev Devuelve la información de las comisiones a los ganadores en btx.
     @return comissionCancelBetBtx
     */
    function getComissionCancelBetBtx() external view returns(uint256);
}