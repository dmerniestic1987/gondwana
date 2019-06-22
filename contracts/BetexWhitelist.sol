pragma solidity 0.5.2;

/**
 * @dev Permite a los usuarios autoexcluirse de la plataforma Betex
 */
contract BetexWhitelist {
    mapping(address => bool) internal whitelist;

    /**
     * @dev Agrega a un address determinado a la lista de autoexcluídos
     */
    function addToWhiteList(address _address) internal{
        whitelist[_address] = true;
    }
}
