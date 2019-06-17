pragma solidity 0.5.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
/**
 * @dev BetexToken son los tokens que se utilizarán para las apuestas. 
 * La emisión origina es de 2^255 BTX y no tiene decimales. Los tokens
 * no son divisibles.
 */
contract BetexToken is ERC20Detailed, ERC20Mintable {    
    constructor() public ERC20Detailed("Betex Token", "BTX", 10) {
        _mint(msg.sender, (2**255) * (10 ** uint256(decimals())));
    }
}