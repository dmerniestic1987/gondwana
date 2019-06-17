pragma solidity 0.5.2;

import "./BetexAccessControl.sol";

contract BetexSettings is BetexAccessControl{
    uint256 public minBetAmount;
    uint256 public maxBetAmount;
    
    //Apuesta mínima
    uint256 public minimumStake;
    
    //Comisión que se le cobra al ganador de la apuesta
    uint256 public commission;

    //Ganancias totales acumuladas
    uint256 internal gain;

    event SettedCommision(uint256 oldComission, uint256 newComission); 
    event SettedStake(uint256 oldMinStake, uint256 newMinStake); 

    /**
     * @dev Setea el monto mínimo de apuestas permitidos. El porcentaje que se le cobra
     *      es sobre el total que ganó
     * @param _commission Es la comisión que le cobra al ganador de una apuesta
     */
    function setCommission(uint256 _commission) public onlyCFO(){
        require(_commission > 0 && _commission <= 100, "Porcentaje incorrecto");
        uint256 oldComission = commission;
        commission = _commission;
        emit SettedCommision(oldComission, commission);
    }

    /**
     * @dev Setea el monto mínimo de apuestas permitidos
     * @param _minStake Mínimo permitido en wei
     */
    function setMinimunStake(uint256 _minStake) public onlyMarketManager(){
        uint256 oldMinStake = minimumStake;
        minimumStake = _minStake;
        emit SettedStake(oldMinStake, minimumStake);
    }
}