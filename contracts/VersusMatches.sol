pragma solidity >= 0.5.0;
import "./Ownable.sol";

contract VersusMatches is Ownable{
    uint8 constant private LOCAL_COMPETITOR   = 0;
    uint8 constant private VISITOR_COMPETITOR = 1;

    event NewMatch(uint id, uint256 idLaurasia, uint128 competition);

    enum MatchStatus { PENDING, PLAYING, SUPENDED, FINISHED, REPROGRAMMED }
    enum MatchDefinition { NO_DEFINITION, KO, TKO, SUBMISSION, DECLASSIFICATION, DESERTION, TIME_OUT }
    
    struct MatchResult{
        bool  draw;
        string winner;
        string looser;
        MatchDefinition definition;
        uint32 scoreWinner;
        uint32 scoreLooser;
    }

    struct Match{
        uint256 idLaurasia;
        uint128 competition;
        uint128 matchType;
        MatchStatus status;
        mapping(uint8=>uint) competitors;
    }

    mapping(uint128 => string) public matchTypes;
    
    //Key: Id de Match
    Match[] public matches; 
    
    //Key: Id de Match
    mapping(uint256 => MatchResult) public matchesResults; 

    //Verifica si existe un resultado de match. Key: Id del Match
    mapping(uint256 => bool) private matchesResultChecker;    

    //Verifica si existe un match. Key: Id del Match
    mapping(uint256 => bool) private matchesChecker; 
    mapping(uint256 => bool) private matchesCheckerLaurasia;

    //Verifica si existe un match. Key: Id del tipo de Match, por ejemplo deporte
    mapping(uint128 => bool) public matchTypesChecker;

    function getBalance() public view returns (uint){
        return address(this).balance;
    }

    function addMatchType(uint128 _idMatchType, string memory _description) public onlyOwner(){
        require(!matchTypesChecker[_idMatchType], "MT0001 MATCH TYPE EXISTS");
        matchTypes[_idMatchType] = _description;
        matchTypesChecker[_idMatchType] = true;
    }       

    function createMatch( uint256 _idLaurasia, uint128 _competition, uint128 _idMatchType
                        , uint _idLocal, uint _idVisitor ) external onlyOwner(){
        
        require(matchTypesChecker[_idMatchType], "MT0002 MATCH TYPE DOES NOT EXIST");     
        require(!matchesCheckerLaurasia[_idLaurasia], "MH0001 MATCH WITH LARUASIA ID ALREADY EXISTS");  

        uint id = matches.push(Match(_idLaurasia, _competition, _idMatchType, MatchStatus.PENDING));
        matches[id].competitors[LOCAL_COMPETITOR] = _idLocal;
        matches[id].competitors[VISITOR_COMPETITOR] = _idVisitor;
        matchesChecker[id] = true;
        matchesCheckerLaurasia[_idLaurasia] = true;
        emit NewMatch(id, _idLaurasia, _competition);                    
    }
}