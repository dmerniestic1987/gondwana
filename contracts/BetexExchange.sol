pragma solidity >= 0.5.0;
import "./BetexToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract BetexExchange is Ownable{
    BetexToken public betexToken;
    
    function initialize(address _address) external onlyOwner() {
        betexToken = BetexToken(_address);
    } 
}