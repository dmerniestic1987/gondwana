pragma solidity 0.5.2;

/**
 * @dev Permite a los usuarios autoexcluirse de la plataforma Betex
 */
contract BetexSelfExcluded {
    mapping(address => bool) internal selfExcluded;

    /**
     * @dev Agrega a un address determinado a la lista de autoexcluídos
     */
    function selfExclude() external {
        selfExcluded[msg.sender] = true;
    }

    /**
     * @dev Verifica si una dirección de wallet forma parte de los autoexcluidos
     */
    function isSelfExcluded(address _address) external view returns(bool) {
        return selfExcluded[_address];
    }
}
