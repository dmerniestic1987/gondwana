pragma solidity 0.5.2;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title BetexAccessControl
 * @dev Este contrato permite definir los roles específicos de las personas para 
 *      restringir el acceso a ciertas funcionalidades. Los roles son: 
 *      - CFO: Chief Finantial Officer: El resposable de administrar los fondos. 
 *      - MarketManager: El encagado de administrar los mercados de apuestas.
 *      - Owner: Es el dueño del contrato, en este caso el de BETEX. Respeta el contrato Ownable
 */
contract BetexAccessControl is Ownable{
    address public marketManagerAddress;
    address public cfoAddress;

    string internal constant NOT_ALLOWED = "NA0001 NOT ALLOWED";
    string internal constant ADDRESS_NOT_OWNER = "NA0002 THE ADDRESS SHOULD NOT BE THE OWNER'S";

    event SettedCFO(address oldAddress, address newAddress);
    event SettedMarketManager(address oldAddress, address newAddress);

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
    function setCFO(address _cfo) external onlyOwner() {
        require(_cfo != owner(), ADDRESS_NOT_OWNER);
        address oldCfo = cfoAddress;
        cfoAddress = _cfo;
    
        emit SettedCFO(oldCfo, cfoAddress);
    }
    
   /**
    * @dev Setea a un nuevo administrador de mercado de apuuestas.
    * @param _marketManager Dirección del Market Manager
    */
    function setMarketManager(address _marketManager) external onlyOwner() {
        require(_marketManager != owner(), ADDRESS_NOT_OWNER);
        address oldManagerAddress = marketManagerAddress;
        marketManagerAddress = _marketManager;

        emit SettedMarketManager(oldManagerAddress, marketManagerAddress);
    }
}