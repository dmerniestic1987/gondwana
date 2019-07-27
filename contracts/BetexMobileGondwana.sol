pragma solidity 0.5.2;

import "./IBetexMobileGondwana.sol";
import "./BetexAuthorization.sol";
import "./BetexSettings.sol";
import "./BetexSelfExcluded.sol";
import "./BetexCore.sol";

/**
 * @dev Este contrato es el Proxy con el que el usuario de la aplicación 
 * móvil puede comunicarse con la plataforma Betex. 
 */
contract BetexMobileGondwana is IBetexMobileGondwana, BetexAuthorization {
    BetexSettings public betexSettings;
    BetexSelfExcluded public betexSelfExcluded;
    BetexCore public betexCore;

    /**
     * @dev Sólo puede ser initializado una vez
     * @param _better Address del apostador
     */
    modifier notSelfExcluded(address _better) {
        require(!betexSelfExcluded.isSelfExcluded(_better), "Self excluded better");
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
    function saveUserSettings( uint256 _amountWeiPerDay, uint256 _amountBtxPerDay, uint256 _maxBetsPerDay) external {
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
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _marketRunnerHash sha3 (marketId + runnerId)
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack true si la apuesta es a favor, false de lo contrario
     */
    function placeMarketBetBtx(
        bytes32 _marketRunnerHash,
        uint256 _odd, 
        uint256 _stake, 
        bool _isBack) external {

        betexCore.placeMarketBetBtx(msg.sender, _marketRunnerHash, _odd, _stake, _isBack);
    }

    /** 
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _marketRunnerHash sha3 (marketId + runnerId)
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack true si la apuesta es favor, false de lo contrario
    */    
    function placeMarketBetWei(
        bytes32 _marketRunnerHash,
        uint256 _odd, 
        uint256 _stake, 
        bool _isBack) external payable {
        
        uint256 amount = msg.value;
        betexCore.placeMarketBetWei(msg.sender, _marketRunnerHash, _odd, _stake, _isBack);
    }


    /**
     * @dev Cancela una apuesta de mercado. Tiene asociado un costo de comisión
     * @param _betId id de la apuesta
     */
    function cancelMarketBet(uint256 _betId) external {
        betexCore.cancelMarketBet(msg.sender, _betId);
    }

    /**
     * @dev Cobra una apuesta ganadora. Tiene asociado un costo de comisión
     * @param _betId id de la apuesta
     */
    function chargeMarketBet(uint256 _betId) external {
        betexCore.chargeMarketBet(msg.sender, _betId);
    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash sha3(marketId + runnerId)
     * @return (maxBackOdd, maxLayOdd): Cuota máxima a favor y en contra
     */
    function getMaxOdds(bytes32 _marketRunnerHash) external view returns(uint256, uint256) {
        return betexCore.getMaxOdds(_marketRunnerHash);
    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash sha3(marketId + runnerId)
     */
    function createP2PBetWei(bytes32 _marketRunnerHash) 
    external payable notSelfExcluded(msg.sender) {
        uint256 amount = msg.value;
        betexCore.createP2PBetWei(msg.sender, _marketRunnerHash, amount);
    }

    /**
     * @dev Obtiene los Max Odds hasta el momeno de un mercado y runner específico.
     * @param _marketRunnerHash sha3(marketId + runnerId)
     * @param _amountBtx monto en Btx
     */
    function createP2PBetBtx(bytes32 _marketRunnerHash, uint256 _amountBtx) 
    external notSelfExcluded(msg.sender) {
        betexCore.createP2PBetBtx(msg.sender, _marketRunnerHash, _amountBtx);
    }

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     * @param _amount hashId
     */
    function acceptP2PBetBtx(uint256 _betId, uint256 _amount) external notSelfExcluded(msg.sender) {
        betexCore.acceptP2PBetBtx(msg.sender, _betId, _amount);
    }

    /**
     * @dev Acepta una apuesta P2P(directa) que esté abierta
     * @param _betId id of bet
     */
    function acceptP2PBetWei(uint256 _betId) external payable {
        uint256 amount = msg.value;
        betexCore.acceptP2PBetWei(msg.sender, _betId, amount);
    }

    /**
     * @dev Cancela una apuesta P2P(directa) que esté abierta y sin matcheo
     * @param _betId id of bet
     */
    function cancelP2PBet(uint256 _betId) external {
        betexCore.cancelP2PBet(msg.sender, _betId);
    }

    /**
     * @dev Un usuario rechaza una apuesta P2P
     * @param _betId id of bet
     */
    function refuseP2PBet(uint256 _betId) external {
        betexCore.refuseP2PBet(msg.sender, _betId);
    }

    /**
     * @dev Un usuario cobra una apuesta P2P
     * @param _betId id of bet
     */
    function chargeP2PBet(uint256 _betId) external {
        betexCore.chargeP2PBet(msg.sender, _betId);
    }    

    /**
     * @dev Devuelve la cantidad máxima por defaul que los usuarios pueden apostar al día.
     * El usuario puede guardar su propia configuración
     * @return defaultMaxAmountWeiPerDay
     */
    function getDefaultMaxAmountWeiPerDay() external returns (uint256) {
        return betexSettings.getDefaultMaxAmountWeiPerDay();
    }

    /**
     * @dev Devuelve la cantidad máxima por defaul que los usuarios puede apostar al día.
     * El usuario puede guardar su propia configuración
     * @return defaultMaxAmountBtxPerDay expresado en btx
     */
    function getDefaultMaxAmountBtxPerDay() external returns (uint256) {
        return betexSettings.getDefaultMaxAmountBtxPerDay();
    }

    /**
     * @dev Devuelve la cantidad máxima de apuestas per cápitla que los 
     * usuarios pueden hacer al día. El usuario puede guardar su propia configuración
     * @return defaultMaxBetsPerDay cantidad
     */
    function getDefaultMaxBetsPerDay() external returns (uint256) {
        return betexSettings.getDefaultMaxBetsPerDay();
    }

    /**
     @dev Devuelve el monto mínimo de apuestas permitadas en wei.
     @return minStakeWei
     */
    function getMinStakeWei() external view returns(uint256) {
        return betexSettings.getMinStakeWei();
    }

    /**
     @dev Devuelve el monto máximo de apuestas permitadas en wei.
     @return maxStakeWei
     */
    function getMaxStakeWei() external view returns(uint256) {
        return betexSettings.getMaxStakeWei();
    }

    /**
     @dev Devuelve el monto mínimo de apuestas permitadas en BTX.
     @return minStakeBtx
     */
    function getMinStakeBtx() external view returns(uint256) {
        return betexSettings.getMinStakeBtx();
    }

    /**
     @dev Devuelve el monto máximo de apuestas permitadas en BTX.
     @return maxStakeBtx
     */
    function getMaxStakeBtx() external view returns(uint256) {
        return betexSettings.getMaxStakeBtx();
    }

    /**
     @dev Devuelve la información de las comisiones de los ganadores de apuestas en wei.
     @return comissionWinnerBetWei
     */
    function getComissionWinnerBetWei() external view returns(uint256) {
        return betexSettings.getComissionWinnerBetWei();
    }

    /**
     @dev Devuelve la información de las comisiones por cancelación de apuetas en wei.
     @return comissionCancelBetWei
     */
    function getComissionCancelBetWei() external view returns(uint256) {
        return betexSettings.getComissionCancelBetWei();
    }

    /**
     @dev Devuelve la información de las comisiones a los ganadores en btx.
     @return comissionWinnerBetBtx
     */
    function getComissionWinnerBetBtx() external view returns(uint256) {
        return betexSettings.getComissionWinnerBetBtx();
    }

    /**
     @dev Devuelve la información de las comisiones a los ganadores en btx.
     @return comissionCancelBetBtx
     */
    function getComissionCancelBetBtx() external view returns(uint256) {
        return betexSettings.getComissionCancelBetBtx();
    }

    /**
     * @dev verifica si una apuesta fue ganadora
     * @param _betId id de apuesta
     * @return true si ganó, false de lo contrario
     */
    function isWinner(uint256 _betId) external view returns (bool) {
        return false;
    }

    /**
     * @dev Inicializa el contrato
     * @param _betexSettings Dirección del contrato de configuración
     * @param _betexSelfExcluded Dirección del contrato de autoexcluídos
     */
    function init(address _betexSettings, address _betexSelfExcluded, address _betexCore) 
    onInitialize() onlyOwner() public {
        betexSettings = BetexSettings(_betexSettings);
        betexSelfExcluded = BetexSelfExcluded(_betexSelfExcluded);
        betexCore = BetexCore(_betexCore);
    }
}