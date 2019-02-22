pragma solidity >= 0.5.0;
import "./BetexBase.sol";

contract BetexCore is BetexBase{

    constructor() public {
        owner = msg.sender;
        marketManagerAddress = msg.sender;
        cfoAddress = msg.sender;
        minimumStake = 0.01 ether;
        commission = 5; //Se cobra el 5% de comisión del payout al ganador
        gain = 0;
        //Creamos el mercado y la apuesta génesis
        openMarket(0);
        _createBet(0, 0, 1, BetType.BACK, 0, 0, BetStatus.CLOSED); 
    }

    /**
    * @dev Resuelve las apuestas de un mercado determinado
    * @param _marketId Id del mercado en Laurasia
    * @param _winnerRuner Id del runner ganador del mercado
    * @param _losserRunners Array de los ID de los runners de los pededores del mercado 
    */
    function resolveBetByMarket( uint128 _marketId
                               , uint64 _winnerRuner
                               , uint64[] memory _losserRunners) public onlyMarketManager(){
        
        _resolveBackBets(_marketId, _winnerRuner);
        
        for (uint i = 0; i < _losserRunners.length; i++){
            _resolveBackBets(_marketId, _losserRunners[i]);
        } 
    }
    /**
     * @dev Obtiene la lista de de las apuestas en contra
     * @param _marketId ID del mercado
     * @param _runnerId ID del runner en el mercado
     * @param _betType Tipo de apuesta
     */
    function getPlacedBets(uint128 _marketId, uint64 _runnerId, BetType _betType ) 
            public view returns (uint[] memory ){
        bytes32 placedBetKey = _keyResolver(_marketId, _runnerId, _betType);
        return placedBets[placedBetKey];
    }

    /**
     * @dev Obtiene la lista de las apuestas matcheadas
     * @param _betId es el ID de la apuesta que se quiere consultar
     */
    function getMatchedBets(uint _betId) public view returns(uint[] memory){
        require(_betId < bets.length, "El id no existe");
        return matchedBets[_betId];
    } 

    /**
     * Verifica si ganó una apuesta determinada
     * @param _betId ID de la apuesta
     * @return true si ganó, false de lo contrario
     */
    function isBetWinner(uint _betId) public view returns(bool){
        require(_betId < bets.length, "El ID ingresado no existe");
        Bet memory bet = bets[_betId];
        bytes32 marketResultKey = _keyResolver(bet.marketId, bet.runnerId, bet.betType );
        return marketResultWinners[marketResultKey];
    }

    /**
     * @dev permite realizar una apuesta a favor de un Runner determinado. Para calcular
     *      Por ejemplo Barcelona V.S PSG. Si apostamos en 10 ether A fovor de PSG a un odd 3.4: 
     *         - Si Gana el PSG, se pierden Gana 24 ether
     *         - Si Gana Barza o Empata, se pierden 10 ether.
     *      
     * @param _marketId Id en Laurasia
     * @param _runnerId Id Runner en Laurasia
     * @param _odd cuota. El valor decimal en uint. Si en al app el apostador ingresa 1.41, acá llega 141
     * @param _stake Es el monto que se pone en una apuesta
     * @param _counterBetId ID de la apuesta contra la que se apuesta. Si es 0, significa que es un nuevo odd
     */
    function placeBackBet( uint128 _marketId, uint64 _runnerId, uint64 _odd, uint _stake
                        , uint _counterBetId) external payable minStake() minOdd(_odd){
        require(msg.value == _stake, "LAY: Stake y Odd no coinciden con lo apostado");
        _placeBet(_marketId, _runnerId, _odd, _stake, BetType.BACK, _counterBetId);
    }

    /**
     * @dev permite realizar una apuesta en contra de un Runner determinado. Para calcular
     *      el dinero que debe ingresar el apostador se debe realizar el siguiente cálculo: 
     *      msg.value = (odd - 100) * stake. 
     *      Por ejemplo Barcelona V.S PSG. Si apostamos en 10 ether Contra de PSG a un odd 3.4: 
     *         - Si Gana el PSG, se pierden 24 ether
     *         - Si Gana Barza o Empata, se ganan 10 ether.
     *      msg.value = (3.4 - 1) * 10 ether = 24 ether

     * @param _marketId Id en Laurasia
     * @param _runnerId Id Runner en Laurasia
     * @param _odd cuota. El valor decimal en uint. Si en al app el apostador ingresa 1.41, acá llega 141
     * @param _stake Es el monto que se pone en una apuesta
     * @param _counterBetId ID de la apuesta contra la que se apuesta. Si es 0, significa que es un nuevo odd
     */
    function placeLayBet( uint128 _marketId, uint64 _runnerId, uint64 _odd, uint _stake
                        , uint _counterBetId) external payable minStake() minOdd(_odd){
        uint liability = ( _odd - 100 ) * _stake / 100;
        require(msg.value == liability, "LAY: Stake y Odd no coinciden con lo apostado");
        _placeBet(_marketId, _runnerId, _odd, _stake, BetType.LAY, _counterBetId);
    }    
}