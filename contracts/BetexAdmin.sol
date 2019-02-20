pragma solidity >= 0.5.0;
import "./BetexAccessControl.sol";

contract BetexAdmin is BetexAccessControl{
    //Apuesta mínima
    uint public minimumStake;
    
    //Comisión que se le cobra al ganador de la apuesta
    uint public commission;
    
    //Mercados de las apuestas
    mapping(uint => bool) public marketsExists;  

    /**
    * @dev Verifica que haya un mínimo stake
     */
    modifier minStake(){
        require(msg.value >= minimumStake, "No llegó a la apuesta mínima");
        _;
    }

    /**
     * @dev Setea el monto mínimo de apuestas permitidos
     * @param _commission Es la comisión que le cobra al ganador de una apuesta
     */
    function setCommission(uint _commission) public onlyCFO(){
        require(_commission > 0 && _commission <= 100, "Porcentaje incorrecto" );
        commission = _commission;
    }

    /**
     * @dev Setea el monto mínimo de apuestas permitidos
     * @param _minStake Mínimo permitido en wei
     */
    function setMinimunStake(uint _minStake) public onlyMarketManager(){
        minimumStake = _minStake;
    }

    /**
     * @dev Agrega un mercado a la base de datos
     * @param _marketIdLaursia Id en Laurasia
     */
    function addMarket(uint _marketIdLaursia) public onlyMarketManager(){
        marketsExists[_marketIdLaursia] = true;
    }    
}    