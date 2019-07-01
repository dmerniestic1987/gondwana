pragma solidity 0.5.2;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title BetexAuthorization
 * @dev Este contrato permite definir los roles específicos de las personas para 
 *      restringir el acceso a ciertas funcionalidades. Los roles son: 
 *      - CTO: Chief Technology Officer: El resposable algunos aspectos técnicos de Betex
 *      - MarketManager: El encagado de administrar los mercados de apuestas.
 *      - Owner: Es el dueño del contrato, en este caso el de BETEX.
 */
 //TODO: 30/06/2018 Los seteos críticos deberían hacerse a través de contratos de votación
contract BetexAuthorization is Ownable {
    address private marketManagerAddress;
    address private ctoAddress;
    mapping(address => bool) private whitelist;
    bool internal initialized;

    event SettedCTO(address newAddress);
    event SettedMarketManager(address newAddress);
    event RemovedFromWitheList(address removedAddress);
    event AddedToList(address removedAddress);
    
    /**
     * @dev Sólo puede ser initializado una vez
     */
    modifier onInitialize() {
        require(!initialized, "Contract already initialized");
        _;
    }

    /**
    * @dev Invocado cuando se realizan operaciones de administración de mercados de apuestas.
    */
    modifier onlyMarketManager() {
        require(msg.sender == marketManagerAddress, "You are not allowed");
        _;
    }

    /**
    * @dev Invocado cuando se realizan operaciones de administración de finanzas.
    */
    modifier onlyCTO() {
        require(msg.sender == ctoAddress, "You are not allowed");
        _;
    }

    modifier onlyWhitelist(){
        require(whitelist[msg.sender], "Not allowed");
        _;
    }

    /**
    * @dev Setea a un nuevo CTO.
    * @param _cto Dirección del CTO
    */
    function setCTO(address _cto) external onlyOwner() {
        require(_cto != owner(), "Onwer must not be CTO");
        ctoAddress = _cto;    
        
        emit SettedCTO(ctoAddress);
    }
    
   /**
    * @dev Setea a un nuevo administrador de mercado de apuuestas.
    * @param _marketManager Dirección del Market Manager
    */
    function setMarketManager(address _marketManager) external onlyOwner() {
        require(_marketManager != owner(), "Onwer must not be MarketManager");
        marketManagerAddress = _marketManager;

        emit SettedMarketManager(marketManagerAddress);
    }

    /**
     * @dev Obtiene la dirección seteada del market manager
     * @return marketManagerAddress
     */
    function getMarketManager() external view onlyOwner() returns (address) {
        return marketManagerAddress;
    }

    /**
     * @dev Obtiene la dirección del CTO
     * @return ctoAddress
     */
    function getCTO() external view onlyOwner() returns (address) {
        return ctoAddress;
    }

    /**
     * @dev Elimina una dirección de la whitelist
     * @param _address Dirección en la que ya no se puede confiar
     */
    function removeFromWhiteList(address _address) external onlyOwner() {
        require(whitelist[_address], "Not withelisted");
        whitelist[_address] = false;
        emit RemovedFromWitheList(_address);
    }

    /**
     * @dev Agrega a un address determinado a la whitelist
     * @param _address Dirección en la que se puede confiar
     */
    function addToWhiteList(address _address) internal {
        require(!whitelist[_address], "Already withelisted");
        whitelist[_address] = true;
        emit AddedToList(_address);
    }
}