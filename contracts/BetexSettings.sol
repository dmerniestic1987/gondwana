pragma solidity 0.5.2;

import "./BetexAuthorization.sol";

/**
 * @title BetexSettings
 * @dev Este contrato permite guardar los parámetros de configuración
 * de la plataforma. También permite a los usuarios registrar sus propios
 * parámetros de configuración.
 */
contract BetexSettings is BetexAuthorization {
    event UserSettingsUpdate(uint256 amountWeiPerDay, uint256 amountBtxPerDay, uint256 maxBetsPerDay);

    //Valor por default del monto máximo en wei que se puede apostar a diario
    uint256 public defaultMaxAmountWeiPerDay;
    //Valor por default del monto máximo en btx que se puede apostar a diario
    uint256 public defaultMaxAmountBtxPerDay;
    //Valor por defecto de las máxima cantidad de apuesas diarias
    uint256 public defaultMaxBetsPerDay;
    //Monto mínimo de la apuesta en BTX
    uint256 public minStakeBtx;
    //Monto mínimo de la apuesta en wei
    uint256 public minStakeWei;
    //Monto máximo de la apuesta en BTX
    uint256 public maxStakeBtx;
    //Monto máximo de la apuesta en WEI
    uint256 public maxStakeWei;
    //Comisión que se le cobra a los ganades de apuetas en WEI. Expresado en porcentaje
    uint256 public comissionWinnerBetWei;
    //Comisión que se le cobra a los que cancelan apuestas en WEI. Expresado en porcentaje
    uint256 public comissionCancelBetWei;
    //Comisión que se le cobra a los ganades de apueats en BTX. Expresado en porcentaje
    uint256 public comissionWinnerBetBtx;
    //Comisión que se le cobra a los que cancelan apuestas en WEI. Expresado en porcentaje
    uint256 public comissionCancelBetBtx;

    struct UserSettings {
        //Max monto en wei que puede apostar por día
        uint256 maxAmountWeiPerDay;      
        //Max monto en btx que puede apostar por día
        uint256 maxAmountBtxPerDay;     
        //Max cantidad de apuestas que puede realiar por día, sin importar la moneda
        uint256 maxBetsPerDay;        
        //True si tiene configuración del usuario
        bool userConfig;
    }
    
    mapping(address => UserSettings) public userSettings;
    
    /**
     * @dev Obtiene la configuración de los usuarios. En caso de no haber una
     * devuleve los valores por default
     * @param _userAddress dirección de un usuario
     * @return (maxAmountWeiPerDay, maxAmountBtxPerDay, maxBetsPerDay )
     */
    function getUserSettings(address _userAddress) public view onlyWhitelist() 
        returns (uint256, uint256, uint256) {
        if (!userSettings[_userAddress].userConfig) {
            return ( defaultMaxAmountWeiPerDay, 
                     defaultMaxAmountBtxPerDay, 
                     defaultMaxBetsPerDay );
        }

        return ( userSettings[_userAddress].maxAmountWeiPerDay, 
                 userSettings[_userAddress].maxAmountBtxPerDay, 
                 userSettings[_userAddress].maxBetsPerDay );
    }

    /**
     @dev Devuelve el monto mínimo de apuestas permitadas en wei.
     @return minStakeWei
     */
    function getMinStakeWei() public view onlyWhitelist() returns(uint256) {
        return minStakeWei;       
    }

    /**
     @dev Devuelve el monto máximo de apuestas permitadas en wei.
     @return maxStakeWei
     */
    function getMaxStakeWei() public view onlyWhitelist() returns(uint256) {
        return maxStakeWei;       
    }

    /**
     @dev Devuelve la información de las comisiones de los ganadores de apuestas en wei.
     @return comissionWinnerBetWei
     */
    function getComissionWinnerBetWei() public view onlyWhitelist() returns(uint256) {
        return comissionWinnerBetWei;       
    }

    /**
     @dev Devuelve la información de las comisiones por cancelación de apuetas en wei.
     @return comissionCancelBetWei
     */
    function getComissionCancelBetWei() public view onlyWhitelist() returns(uint256) {
        return comissionCancelBetWei;       
    }

    /**
     @dev Devuelve la información de las comisiones a los ganadores en btx.
     @return comissionWinnerBetBtx
     */
    function getComissionWinnerBetBtx() public view onlyWhitelist() returns(uint256) {
        return comissionWinnerBetBtx;       
    }

    /**
     @dev Devuelve la información de las comisiones a los ganadores en btx.
     @return comissionCancelBetBtx
     */
    function getComissionCancelBetBtx() public view onlyWhitelist() returns(uint256) {
        return comissionCancelBetBtx;       
    }

    /**
     * @dev Guarda la configuración del usuario determinado
     * @param _userAddress dirección de un usuario
     * @param _maxAmountWeiPerDay máxima cantidad de apuestas de wei por día
     * @param _maxAmountBtxPerDay máxima cantidad de apuestas de btx por día
     * @param _maxBetsPerDay máxima cantidad de apuestas por día
     */
    function saveUserSettings( address _userAddress, uint256 _maxAmountWeiPerDay,
                               uint256 _maxAmountBtxPerDay, uint256 _maxBetsPerDay) 
                               external onlyWhitelist() {
        require(_maxAmountWeiPerDay > minStakeWei, "Max wei amount can not bet lower than minStakeWei");
        require(_maxAmountBtxPerDay > minStakeBtx, "Max btx amount can not bet lower than minStakeBtx");
        require(_maxBetsPerDay > 0, "Max bet per days must be greater than 0");
        userSettings[_userAddress] = UserSettings(_maxAmountWeiPerDay, 
                                                  _maxAmountBtxPerDay, 
                                                  _maxBetsPerDay, 
                                                  true);         
        emit UserSettingsUpdate(_maxAmountWeiPerDay, _maxAmountBtxPerDay, _maxBetsPerDay);                                                           
    }

    /**
     * @dev Setea la cantidad máxima por defaul que los usuarios pueden apostar al día.
     * El usuario puede guardar su propia configuración
     * @param _amount expresado en wei
     */
    function setDefaultMaxAmountWeiPerDay(uint256 _amount) external onlyWhitelist() {
        defaultMaxAmountWeiPerDay = _amount;
    }


    /**
     * @dev Setea la cantidad máxima por defaul que los usuarios puede apostar al día.
     * El usuario puede guardar su propia configuración
     * @param _amount expresado en btx
     */
    function setDefaultMaxAmountBtxPerDay(uint256 _amount) external onlyWhitelist() {
        defaultMaxAmountBtxPerDay = _amount;
    }

    /**
     * @dev Setea la cantidad máxima de apuestas per cápitla que los 
     * usuarios pueden hacer al día. El usuario puede guardar su propia configuración
     * @param _maxBetsPerDay cantidad
     */
    function setDefaultMaxBetsPerDay(uint256 _maxBetsPerDay) external onlyWhitelist() {
        defaultMaxBetsPerDay = _maxBetsPerDay;
    }

    /**
     * @dev Setea el monto mínimo que se aceptan por apuestas
     * @param _minStakeWei monto en wei
     */
    function setMinStakeWei(uint256 _minStakeWei) external onlyWhitelist() {
        minStakeWei = _minStakeWei;
    }

    /**
     * @dev Setea el monto mínimo que se aceptan por apuestas en btx
     * @param _minStakeBtx monto en btx
     */
    function setMinStakeBtx(uint256 _minStakeBtx) external onlyWhitelist() {
        minStakeBtx = _minStakeBtx;
    }


    /**
     * @dev Setea el monto máximo que se aceptan por apuestas
     * @param _maxStakeWei monto en wei
     */
    function setMaxStakeWei(uint256 _maxStakeWei) external onlyWhitelist() {
        maxStakeWei = _maxStakeWei;
    }

    /**
     * @dev Setea el monto máximo que se aceptan por apuestas en btx
     * @param _maxStakeBtx monto en btx
     */
    function setMaxStakeBtx(uint256 _maxStakeBtx) external onlyWhitelist() {
        maxStakeBtx = _maxStakeBtx;
    }

    /**
     * @dev Setea las comisiones que se cobran por apuestas, expresado en porcentaje
     * @param _comissionWinnerBetWei porcentaje entre 0 y 100
     */
    function setComissionWinnerBetWei(uint256 _comissionWinnerBetWei) external onlyWhitelist() {
        comissionWinnerBetWei = _comissionWinnerBetWei;
    }

    /**
     * @dev Setea las comisiones que se cobran por cancelar apuestas en wei
     * @param _comissionCancelBetWei porcentaje entre 0 y 100
     */
    function setComissionCancelBetWei(uint256 _comissionCancelBetWei) external onlyWhitelist() {
        comissionCancelBetWei = _comissionCancelBetWei;
    }

    /**
     * @dev Setea las comisiones que a los ganadores de apuestas en BTX
     * @param _comissionWinnerBetBtx porcentaje entre 0 y 100, con 18 dígitos de precisión
     */
    function setComissionWinnerBetBtx(uint256 _comissionWinnerBetBtx) external onlyWhitelist() {
        comissionWinnerBetBtx = _comissionWinnerBetBtx;
    }

    /**
     * @dev Setea las comisiones que a los que cancelan apuestas en BTX
     * @param _comissionCancelBetBtx porcentaje entre 0 y 100, con 18 dígitos de precisión
     */
    function setComissionCancelBetBtx(uint256 _comissionCancelBetBtx) external onlyWhitelist() {
        comissionCancelBetBtx = _comissionCancelBetBtx;
    }

    /**
     * @dev Inicializa el contrato y agrega a la lista blanca a betexMobile y betexCore
     @param _betexCoreAddress - Dirección del contrato de Betex Core
     @param _defaultMaxAmountWeiPerDay - Monto máximo de apuestas por día en Wei
     @param _defaultMaxAmountBtxPerDay - Monto máximo de apuestas por día en BTX
     @param _defaultMaxBetsPerDay - Cantidad máxima de apuestas por día
     @param _minStakeWei - Monto mínimo que se puede apostar en Wei
     @param _minStakeBtx - Monto mínimo que se puede apostar en BTX
     @param _maxStakeBtx - Monto máximo que se puede apostar en BTX
     @param _maxStakeWei - Monto máximo que se puede apostar en Wei
     @param _comissionWinnerBetWei - Comisión que se le cobra a los ganadores en wei, entre 0 y 1
     @param _comissionCancelBetWei - Comisión que se cobra por cancelar una apuesta en wei, entre 0 y 1
     @param _comissionWinnerBetBtx - Comisión que se le cobra a los ganadores en btx, entre 0 y 1
     @param _comissionCancelBetBtx - Comisión que se cobra por cancelar una apuesta en BTX, entre 0 y 1
     */
    function init(address _betexMobileAddress, 
        address _betexCoreAddress,
        uint256 _defaultMaxAmountWeiPerDay,
        uint256 _defaultMaxAmountBtxPerDay,
        uint256 _defaultMaxBetsPerDay,
        uint256 _minStakeWei,
        uint256 _minStakeBtx,
        uint256 _maxStakeBtx,
        uint256 _maxStakeWei,
        uint256 _comissionWinnerBetWei,
        uint256 _comissionCancelBetWei,
        uint256 _comissionWinnerBetBtx,
        uint256 _comissionCancelBetBtx ) 
        onInitialize() onlyOwner() public {
        defaultMaxAmountWeiPerDay = _defaultMaxAmountWeiPerDay;
        defaultMaxAmountBtxPerDay = _defaultMaxAmountBtxPerDay;
        defaultMaxBetsPerDay = _defaultMaxBetsPerDay;
        minStakeWei = _minStakeWei;
        minStakeBtx = _minStakeBtx;
        maxStakeBtx = _maxStakeBtx;
        maxStakeWei = _maxStakeWei;
        comissionWinnerBetWei = _comissionWinnerBetWei;
        comissionCancelBetWei = _comissionCancelBetWei;
        comissionWinnerBetBtx = _comissionWinnerBetBtx;
        comissionCancelBetBtx = _comissionCancelBetBtx;
        addToWhiteList(_betexMobileAddress);
        addToWhiteList(_betexCoreAddress);
    }
}