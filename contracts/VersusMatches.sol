pragma solidity >= 0.5.0;
import "./Ownable.sol";

/**
 * @title Ownable
 * @dev Este contrato permite registrar eventos deportivos del tipo Versus, es decir
 * uno contra uno, es decir un equipo contra otro, o un combate. Cuando se crea un 
 * nuevo Match se genera un ID único con el cual se puede consultar la información
 * del Match y en caso que ya se sepa el resultado, el resultado del evento con 
 * MatchResult. 
 * En este contrato sólo se almacena los ID de los eventos, compentecias, etc. Si
 * desea conocer el detalle de los competidores, competencias, etc. Su aplicaciónp
 * cliente debe invocar a los servicios de Betex Laursia para obtener la información.
 *
 */
contract VersusMatches is Ownable{
    //Constantes para registrar a un competidor como vistante o local en un Match
    uint8 constant private LOCAL_COMPETITOR   = 0;
    uint8 constant private VISITOR_COMPETITOR = 1;

    //Evento emitido cuando se crea un nuevo Match
    event NewMatch(uint id, uint256 idLaurasia, uint128 competition);

    enum MatchStatus { PENDING, PLAYING, SUPENDED, FINISHED, REPROGRAMMED }
    enum MatchDefinition { NO_DEFINITION        //Por ejemplo partido suspendido
                         , KO, TKO , SUBMISSION //Definición de deportes de combate
                         , DESQULIFICATION      //Descalificación
                         , RETIREMENT           //Retiro o abandono, por ejemplo tira la toalla
                         , SPLIT_DECISION, UNANIMOUS_DECISION, MAYORITY_DECISION, POINTS_DECISION
                         , TIME_OUT             //Se terminó el tiempo para un juador, por ejemplo ajedrez
                         , OTHER }
    
    //MatchType puede ser por ejemplo Fútbol, Boxeo, MMA. Se flexibiliza
    //para agregar otros tipos en el futuro.
    struct MatchType{
        bool canDraw;       //true si se puede empatar, false de lo contrario
        string description; //descripción
        uint matchCounter;  //Permite contar la cantidad de matces registrados
    }

    //Match corresponde aun evento determinado, por ejemplo un partido de Fútbol
    //o un combate de artes marciales mixtas.
    struct Match{
        uint128 competition;  //id de la competición en Betex Laurasia
        uint128 matchType;    //id del tipo de match, en el contrato   
        uint    startDate;    //timestamp del inicio del evento.
        MatchStatus status;   //estado  
    }

    //MatchResult permite registrar el resultado de un evento deporitvo
    struct MatchResult{
        MatchDefinition definition; //tipo de definción
        bool  draw;                 //true si empataron.
        uint128 winner; //id del ganador  en Betex Laurasia. Si es empate va 0.
        uint128 looser; //id del pertedor en Betex Laurasia. Si es empate va 0.
        uint32 scoreWinner; //puntaje del ganador. 
        uint32 scoreLooser; //puntaje del perdedor.
    }

    //Key: Id de Laurasia. Se mantiene uniformidad
    mapping(uint128 => MatchType) public matchTypes;
    
    //Id de match: Índice
    Match[] public matches; 
    
    //Permite determinar el ID de un Match en base al id de Larusia
    mapping(uint256 => uint) private matchesLaurasia;

    //Key: Id de Match
    mapping(uint256 => MatchResult) public matchesResults; 

    //Verifica si existe un resultado de match. Key: Id del Match
    mapping(uint256 => bool) private matchesResultChecker;    

    //Verifica si existe un match. Key: Id del Match
    mapping(uint256 => bool) private matchesChecker; 

    //Verifica si existe un match. Key: Id del tipo de Match, por ejemplo deporte
    mapping(uint128 => bool) private matchTypesChecker;

    // ======================== MATCH TYPES ======================== //
    /**
     * @dev Verifica si existe el MatchType
     * @param _matchTypeId - Id Laurasia del tipo de Match
     * @return true si el tipo de Match Existe, false de lo contrario
     */
    function matchTypeExists(uint128 _matchTypeId) public view returns(bool){
        return matchTypesChecker[_matchTypeId];
    }

    /**
     * @dev Obtiene un MatchType, incluyendo su contador de eventos
     * @param _matchTypeId - Id Laurasia del tipo de Match
     * @return MatchType - La información del MatchType
     */
    function getMatchType(uint128 _matchTypeId) public view returns( bool canDraw, 
                                                                     string memory description, 
                                                                     uint matchCounter ){

        canDraw = matchTypes[_matchTypeId].canDraw;
        description = matchTypes[_matchTypeId].description;
        matchCounter = matchTypes[_matchTypeId].matchCounter;
    }

    /**
     * @dev Crea un nuevo MatchType e inicializa el contador en cero. Dicho contador no se 
     *      modificar una vez creado, ni se puede eliminar el MatchType. En caso de error
     *      en la creción, corregir con updateMatchType 
     * @param _matchTypeId - Id Laurasia del tipo de Match
     * @param _canDraw - true si el tipo de Match permite empate, false de lo contrario
     * @param _description - Descripción del tipo
     */
    function addMatchType(uint128 _matchTypeId, bool _canDraw, string memory _description) public onlyOwner(){
        require(!matchTypesChecker[_matchTypeId], "MT0001 MATCH TYPE EXISTS");
        matchTypes[_matchTypeId] = MatchType(_canDraw, _description, 0);
        matchTypesChecker[_matchTypeId] = true;
    }   

    /**
     * @dev Actauliza un MatchType existente. No reinicia el contador
     * @param _matchTypeId - Id Laurasia del tipo de Match
     * @param _canDraw - true si el tipo de Match permite empate, false de lo contrario
     * @param _description - Descripción del tipo    
     */
    function updateMatchType(uint128 _matchTypeId, bool _canDraw, string memory _description) public onlyOwner(){
        require(matchTypesChecker[_matchTypeId], "MT0002 MATCH TYPE DOES NOT EXIST");
        matchTypes[_matchTypeId].canDraw = _canDraw;
        matchTypes[_matchTypeId].description = _description;
    }   

    // ======================== MATCHES ======================== //
/*
        uint128 competition;  //id de la competición en Betex Laurasia
        uint128 matchType;    //id del tipo de match, en el contrato   
        uint    startDate;    //timestamp del inicio del evento.
        MatchStatus status;   //estado  
        string name;
*/

    function createMatch( uint256 _idLaurasia, uint128 _competition, uint128 _idMatchType
                        , uint _startDateTimestamp ) external onlyOwner(){
        
        require(matchTypesChecker[_idMatchType], "MT0002 MATCH TYPE DOES NOT EXIST");     
        require(matchesLaurasia[_idLaurasia] == 0, "MH0001 MATCH WITH LARUASIA ID ALREADY EXISTS");  

        uint id = matches.push(Match(_competition, _idMatchType,_startDateTimestamp, MatchStatus.PENDING));
        matchesChecker[id] = true;
        matchesLaurasia[_idLaurasia] = id;
        matchTypes[_idMatchType].matchCounter++;
        emit NewMatch(id, _idLaurasia, _competition);                    
    }
}