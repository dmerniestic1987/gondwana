pragma solidity 0.5.2;
import "./BetexAuthorization.sol";
import "./BetexSettings.sol";

/**
 * @dev BetexCore contiene la lógica para poder colocar apuestas, cobrarrlas y
 * calcular las comisiones para la resolución. 
 */
contract BetexCore is BetexAuthorization {
    BetexSettings public betexSettings;
    
    function init(address _betexMobileAddress, address _betexSetting ) 
        onInitialize() onlyOwner() public {
        betexSettings = BetexSettings(betexSettings);
        addToWhiteList(_betexMobileAddress);
    }
}