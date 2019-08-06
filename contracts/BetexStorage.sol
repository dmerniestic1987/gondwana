pragma solidity 0.5.2;

import "./BetexAuthorization.sol";

/**
 * @dev  BetexStorage guarda el estado de Betex.
 */
contract BetexStorage is BetexAuthorization {
    mapping(bytes32 => bool) private marketRunnerWinners;
    
    
}