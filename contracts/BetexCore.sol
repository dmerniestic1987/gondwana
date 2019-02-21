pragma solidity >= 0.5.0;
import "./BetexBase.sol";

contract BetexCore is BetexBase{

    constructor() public {
        owner = msg.sender;
        marketManagerAddress = msg.sender;
        cfoAddress = msg.sender;
        minimumStake = 0.01 ether;
        commission = 5; //Se cobra el 5% de comisión al ganador
        gain = 0;
        //Creamos el mercado y la apuesta génesis
        addMarket(0);
        _createBet(0, 0, 1, BetType.BACK, 0, 0, BetStatus.CLOSED); 
    }
    /**
     * @dev Resuelve las apuestas del tipo BACK
     * @param _marketId Id del mercado en Laurasia
     * @param _winnerRunnerId Id del runner ganador del mercado
     */
    function resolveBackMarkes( uint128 _marketId, uint64 _winnerRunnerId ) public onlyMarketManager(){
        //El mercado tiene que existir
        require(marketsExists[_marketId], "El mercado no existe");

        //TIENEN QUE HABER SUFICIENTES FONDOS EN EL CONTRATO PARA PAGAR EL MERCADO
        //Obtenemos todos los que apostaron a favor del runner Ganador y les pagamos
        bytes32 placedBetKey = _keyResolver(_marketId, _winnerRunnerId, BetType.BACK );
        uint[] memory winnerBackBets = placedBets[placedBetKey];
        
        for (uint i; i < winnerBackBets.length; i++){
            uint winnerBetId = winnerBackBets[i];
            Bet storage bet = bets[winnerBetId];
            address payable bettor = betIndexToOwner[winnerBetId];
            uint payout = 0;
            uint betexGain = 0;
            //Cerramos las apuestas que matchearon completamente.
            //Se paga completamente stake * odd.
            if (bet.betStatus == BetStatus.FULL_MATCHED){  
                emit Print("resolveBacK 1", "Full Matched");
                payout = (bet.odd * bet.stake) / 100;              
                betexGain = (payout * commission) / 100;
                gain += betexGain;
            }
            //Las apuestas fueron parcialmente matcheadas. En este caso
            //devolvemos el total matcheado más el total que no matcheó.
            else if (bet.betStatus == BetStatus.PARTIALLY_MATCHED){
                emit Print("resolveBacK 2", "PARTIALLY Matched");
                uint totalMatched = bet.matchedStake * bet.odd / 100;
                betexGain = (totalMatched * commission) / 100;
                gain += betexGain;
                payout = bet.stake + totalMatched;

            }
            //Las apuestas no matchearon. Se le debe devolver el dinero 
            //de la apuesta si comisión
            else if (bet.betStatus == BetStatus.OPEN) {
                payout = bet.stake;
                emit Print("resolveBacK 3", "OPEN");
            }

            bettor.transfer(payout - betexGain);
            bet.betStatus = BetStatus.CLOSED;
        }

        marketResultWinners[placedBetKey] = true;                              
    }

    /**
     * @dev Obtiene la lista de de las apuestas en contra
     * @param _marketId ID del mercado
     * @param _runnerId ID del runner en el mercado
     * @param _betType Tipo de apuesta
     */
    function getPlacedBets(uint128 _marketId, uint64 _runnerId, BetType _betType ) 
            public view returns (uint[] memory ){
        bytes32 placedBetKey = _keyResolver(_marketId, _runnerId, _betType );
        return placedBets[placedBetKey];
    }

    /**
     * @dev Resuelve las apuestas del tipo BACK
     * @param _marketId Id del mercado en Laurasia
     * @param _looserRunnerId Id del runner perdedor del mercado
     */
    function resolveLayMarket( uint128 _marketId, uint64 _looserRunnerId ) 
        public onlyMarketManager(){
        //El mercado tiene que existir
        require(marketsExists[_marketId], "El mercado no existe");
        emit Print("resolve 2", "Resolvemos los LAY");
        //Obtenemos la lista de los competidors que perdieron, y por cada
        //uno de ellos, traemos las apuestas para resolverlas
        bytes32 placedBetKey = _keyResolver(_marketId, _looserRunnerId, BetType.LAY );
        uint[] memory winnerLayBets = placedBets[placedBetKey];

        // Obtenemos todas las apuestas ganadoras en contra y las liquidamos 
        for (uint i; i < winnerLayBets.length; i++){
            uint winnerBetId = winnerLayBets[i];
            Bet storage bet = bets[winnerBetId];
            address payable bettor = betIndexToOwner[winnerBetId];
            uint payout = 0;
            uint betexGain = 0; 

            //Cerramos las apuestas que matchearon completamente.
            //Se paga completamente stake * odd.
            if (bet.betStatus == BetStatus.FULL_MATCHED){  
                payout = (bet.odd * bet.stake) / 100;              
                betexGain = (payout * commission) / 100;
                gain += betexGain;
                emit Print("resolveLayMarket", "mercado full match");
            }
            //Las apuestas fueron parcialmente matcheadas. En este caso
            //devolvemos el total matcheado más el total que no matcheó.
            else if (bet.betStatus == BetStatus.PARTIALLY_MATCHED){
                uint totalMatched = bet.matchedStake * bet.odd / 100;
                betexGain = (totalMatched * commission) / 100;
                gain += betexGain;

                uint availableLiability = (bet.odd - 100) * (bet.stake - bet.matchedStake) / 100;
                payout = totalMatched + availableLiability;
                emit Print("resolveLayMarket", "mercado partially");

            }
            //Las apuestas no matchearon. Se le debe devolver el dinero 
            //de la apuesta si comisión.
            else if (bet.betStatus == BetStatus.OPEN) {
                payout = (bet.odd - 100) * bet.stake / 100;
                 emit Print("resolveLayMarket", " mercado clossed");
            }

            bettor.transfer(payout - betexGain);
            bet.betStatus = BetStatus.CLOSED;                
        }
        marketResultWinners[placedBetKey] = true;
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