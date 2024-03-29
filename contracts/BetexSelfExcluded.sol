pragma solidity 0.5.10;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @dev Permite a los usuarios autoexcluirse de la plataforma Betex
 */
contract BetexSelfExcluded  is Ownable {
    mapping(address => bool) internal selfExcluded;
    
    event SelfExcluded(address newAddress);
    
    constructor() public {
        //El owner no puede apostar
        selfExcluded[owner()] = true;
    }
    /**
     * @dev Agrega a un address determinado a la lista de autoexcluídos
     */
    function selfExclude() external {
        selfExcluded[msg.sender] = true;
        emit SelfExcluded(msg.sender);
    }

    /**
     * @dev Verifica si una dirección de wallet forma parte de los autoexcluidos
     */
    function isSelfExcluded(address _address) external view returns(bool) {
        return selfExcluded[_address];
    }
}
