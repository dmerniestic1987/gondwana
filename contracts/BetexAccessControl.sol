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

    /**
    * @dev Invocado cuando se realizan operaciones de administración de mercados de apuestas.
    */
    modifier onlyMarketManager() {
        require(msg.sender == marketManagerAddress);
        _;
    }

    /**
    * @dev Invocado cuando se realizan operaciones de administración de finanzas.
    */
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /**
    * @dev Setea a un nuevo CFO.
    * @param _cfo Dirección del CFO
    */
    function setCFO(address _cfo) external onlyOwner{
        require(_cfo != owner);
        cfoAddress = _cfo;
    }
    
   /**
    * @dev Setea a un nuevo administrador de mercado de apuuestas.
    * @param _marketManager Dirección del Market Manager
    */
    function setMarketManager(address _marketManager) external onlyOwner{
        require(_marketManager != owner);
        marketManagerAddress = _marketManager;
    }
}