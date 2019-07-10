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

        /**
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack true si la apuesta es a favor, false de lo contrario
     */
    function placeMarketBetBtx(
        bytes32 _marketHash, 
        bytes32 _runnerHash, 
        uint256 _odd, 
        uint256 _stake, 
        bool _isBack) external onlyWhitelist() {

    }

    /** 
     * @dev Permite colocar apuestas en contra de algún equipo determinado
     * @param _marketHash Hash del mercado
     * @param _runnerHash Hash del runner (equipo o luchador) por le cual se apuesta
     * @param _odd Cuota de apuesta
     * @param _stake monto de la apuesta
     * @param _isBack true si la apuesta es favor, false de lo contrario
    */    
    function placeMarketBetWei(
        bytes32 _marketHash, 
        bytes32 _runnerHash, 
        uint256 _odd, 
        uint256 _stake, 
        bool _isBack) external onlyWhitelist() {

    }

    function init(address _betexMobileAddress, address _betexSetting ) 
        onInitialize() onlyOwner() public {
        betexSettings = BetexSettings(betexSettings);
        addToWhiteList(_betexMobileAddress);
    }
}