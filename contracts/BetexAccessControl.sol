pragma solidity >= 0.5.0;
import "./Ownable.sol";

/**
 * @title BetexAccessControl
 * @dev Este contrato permite restringir los accesos a roles a funcionalidades
 *      del contrato a roles específicos
 */
contract BetexAccessControl is Ownable{
    address public marketManagerAddress;
    address public cfoAddress;
    string internal constant NOT_ALLOWED = "NA0001 NOT ALLOWED";
    string internal constant ADDRESS_NOT_OWNER = "NA0002 THE ADDRESS SHOULD NOT BE THE OWNER'S";
    /**
    * @dev Invocado cuando se realizan operaciones de administración de mercados de apuestas.
    */
    modifier onlyMarketManager() {
        require(msg.sender == marketManagerAddress, NOT_ALLOWED);
        _;
    }

    /**
    * @dev Invocado cuando se realizan operaciones de administración de finanzas.
    */
    modifier onlyCFO() {
        require(msg.sender == cfoAddress, NOT_ALLOWED);
        _;
    }

    /**
    * @dev Setea a un nuevo CFO.
    * @param _cfo Dirección del CFO
    */
    function setCFO(address _cfo) external onlyOwner{
        require(_cfo != owner, ADDRESS_NOT_OWNER);
        cfoAddress = _cfo;
    }
    
   /**
    * @dev Setea a un nuevo administrador de mercado de apuuestas.
    * @param _marketManager Dirección del Market Manager
    */
    function setMarketManager(address _marketManager) external onlyOwner{
        require(_marketManager != owner, ADDRESS_NOT_OWNER);
        marketManagerAddress = _marketManager;
    }
}