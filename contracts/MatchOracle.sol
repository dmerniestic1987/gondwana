pragma solidity >= 0.5.0;
import "./oraclizeAPI.sol";

contract MatchOracle is usingOraclize {
    event newOraclizeQuery(string description);
    event newOraclizeUrl(string description, string url);

    string public queryResult;
    bytes32 public idRequest;

    constructor() public payable{
        oraclize_setProof(proofType_NONE);
    }

    function __callback(bytes32 myid, string memory result) public{
        require(msg.sender == oraclize_cbAddress(), "DIRECCION INVALIDA");
        require(idRequest == myid, "Los ID de request son diferentes en callback");
        queryResult = result;
    }
    
    function update() payable public{
        require(address(this).balance >= oraclize.getPrice("URL"), "El balance no es suficiente");
        string memory url = string(abi.encodePacked("https://laurasia.herokuapp.com/matches/"
                                    , "1", "/", "ethereum"));
        idRequest = oraclize_query("URL", url);
        emit newOraclizeUrl("Invocacion realizada", url);
    }

    function getPriceOriclizeUrl() external returns (uint256){
        return oraclize.getPrice("URL");
    }
    
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
} 
