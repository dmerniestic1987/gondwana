pragma solidity >= 0.5.0;
import "./Ownable.sol";

contract Matches is Ownable{
    enum MatchStatus { PENDING, PLAYING, SUPENDED, FINISHED }
    enum MatchDefinition { NO_DEFINITION, KO, TKO, SUBMISSION, DECLASSIFICATION, DESERTION }
    
    struct MatchResult{
        bool  draw;
        string winner;
        string looser;
        MatchDefinition definition;
        uint32 scoreWinner;
        uint32 scoreLooser;
    }

    struct Match{
        uint128 competition;
        uint128 eventType;
        MatchStatus status;
        mapping(string=>uint) competitors;
    }

    mapping(uint128 => string) public matchTypes;
    
    //Key: Id de Match
    mapping(uint256 => Match) public matches; 
    
    //Key: Id de Match
    mapping(uint256 => MatchResult) public matchesResults; 

    //Verifica si existe un resultado de match. Key: Id del Match
    mapping(uint256 => bool) private matchesResultChecker;    

    //Verifica si existe un match. Key: Id del Match
    mapping(uint256 => bool) private matchesChecker; 




    function addMatchType(uint128 id, string memory description) public onlyOwner(){
        matchTypes[id] = description;
    }            
}