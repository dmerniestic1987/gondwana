    pragma solidity >= 0.5.0;
    import "./BetexAdmin.sol";
    import "./math/SafeMath.sol";

/**
 * @title BetexBase
 * @dev Este contrato define los métodos internos para los métodos y servicios 
 * del contrato BetexCore. 
 */
    contract BetexBase is BetexAdmin{
        using SafeMath for uint256;
        using SafeMath for uint64;

        event PlacedBet(address bettor, uint betId);
        event SolvedBackBets(uint128 marketId);
        event SolvedLayBets(uint128 marketId);

        enum BetType        { BACK, LAY }                                       
        enum BetStatus      { OPEN, PARTIALLY_MATCHED, FULL_MATCHED, CLOSED }   

        struct Bet{
            uint128 marketId;       //Clave del mercado. ID Laurasia
            uint64  runnerId;       //Runner por el que se apuesta. ID Laurasia     
            uint64  odd;            //Es la cuota. El sistema sólo permite 2 decimal. Si es 2,73, guardo como 273. 
            uint stake;             //Es el monto apostado en WEI. Para BACK debe coincidir con msg.value      
            uint matchedStake;      //Es la cantidad de diner que hasta el momento se pudo matchear contra otras apuestas. 
                                    //Si stake == matchedStake significa que la apuesta quedó en OPEN_MATCHED
            BetType betType;        //Tipo de apuesta. Back: A favor, Lay: En contra
            BetStatus betStatus;    //Estado de la apuesta 
        }

        //Guarda las apuestas con ID único  
        Bet[] public bets;         
        
        //Agrupa las apuestas por tipo de Mercado.  //Key: MarketId  //Value: Id - array índices de bets
        mapping(uint128 => uint[]) public betsByMarket; 

        //Permite obtener los indices de todas las puestas de una dirección en particular
        mapping(address => uint[]) internal ownerToBetsIndex; 
                                                            
        //Permite determinar al  emisor de una apuesta
        mapping(uint => address payable) internal betIndexToOwner;                                          

        //Permite conocer cual fue el resultado de un mercado dado el ID de mercado y el runner
        mapping(bytes32 => bool) internal marketResultWinners;

        //Permite resolver las apuestas de una manera más eficiente
        mapping(bytes32 => uint[]) internal placedBets;

        mapping(bytes32 => uint[]) internal placedBetByOdds;    
        
        /**
        * @dev Verifica que se cumpla con el mínimo ODD
        */
        modifier minOdd(uint64 _odd){
            require(_odd > 100, "La cuota debe ser mayor a 100");
            _;
        }

        /**
        * @dev Resuelve las apuestas del tipo BACK
        * @param _marketId Id del mercado en Laurasia
        * @param _winnerRunnerId Id del runner ganador del mercado
        */
        function _resolveBackBets( uint128 _marketId, uint64 _winnerRunnerId ) internal{
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
                    payout = (bet.odd.mul(bet.stake)).div(100);              
                    betexGain = (payout.mul(commission)).div(100);
                    gain = gain.add(betexGain);
                }
                //Las apuestas fueron parcialmente matcheadas. En este caso
                //devolvemos el total matcheado más el total que no matcheó.
                else if (bet.betStatus == BetStatus.PARTIALLY_MATCHED){
                    uint totalMatched = (bet.matchedStake.mul(bet.odd)).div(100);
                    betexGain = (totalMatched.mul(commission)).div(100);
                    gain = gain.add(betexGain);
                    payout = (bet.stake.sub(bet.matchedStake)).add(totalMatched);

                }
                //Las apuestas no matchearon. Se le debe devolver el dinero 
                //de la apuesta si comisión
                else if (bet.betStatus == BetStatus.OPEN) {
                    payout = bet.stake;
                }

                require(address(this).balance >= payout - betexGain, "_resolveBackBet - Sin fondos");
                bettor.transfer(payout - betexGain);
                bet.betStatus = BetStatus.CLOSED;
            }

            marketResultWinners[placedBetKey] = true;                              
        }

        /**
        * @dev Resuelve las apuestas del tipo BACK
        * @param _marketId Id del mercado en Laurasia
        * @param _looserRunnerId Id del runner perdedor del mercado
        */
        function _resolveLayBets( uint128 _marketId, uint64 _looserRunnerId ) internal {
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
                    payout = (bet.odd.mul(bet.stake)).div(100);              
                    betexGain = (payout.mul(commission)).div(100);
                    gain = gain.add(betexGain);
                }
                //Las apuestas fueron parcialmente matcheadas. En este caso
                //devolvemos el total matcheado más el total que no matcheó.
                else if (bet.betStatus == BetStatus.PARTIALLY_MATCHED){
                    uint totalMatched = (bet.matchedStake.mul(bet.odd)).div(100);
                    betexGain = (totalMatched.mul(commission)).div(100);
                    gain = gain.add(betexGain);

                    uint availableLiability = ((bet.odd.sub(100)).mul((bet.stake.sub(bet.matchedStake)))).div(100);
                    payout = totalMatched.add(availableLiability);
                }
                //Las apuestas no matchearon. Se le debe devolver el dinero 
                //de la apuesta si comisión.
                else if (bet.betStatus == BetStatus.OPEN) {
                    payout = ((bet.odd.sub(100)).mul(bet.stake)).div(100);
                }
                
                require(address(this).balance >= payout.sub(betexGain), "Sin fondos");
                bettor.transfer(payout.sub(betexGain));
                bet.betStatus = BetStatus.CLOSED;                
            }
            marketResultWinners[placedBetKey] = true;
        }

        /**
        * @dev Registra una nueva apuesta para un mercado y un runner determinado
        * @param _marketId Id en Laurasia
        * @param _runnerId Runner en Laurasia
        * @param _odd cuota. El valor decimal se transforma a uint. Si en al app el apostador ingresa 1.41, acá llega 141
        * @param _stake Es el monto que se pone en una apuesta
        * @param _betType tipo de apuesta
        */
        function _placeBet( uint128 _marketId, uint64 _runnerId, uint64 _odd, uint _stake
                           , BetType _betType) internal{
            
            //Verificamos si existen contraapuestas registradas
            uint betId = 0;
            BetType counterBetType = BetType.BACK;
            if (_betType == BetType.BACK){
                counterBetType = BetType.LAY;
            }
            //Esta es la clave del mapping para ir a buscar las contrapuestas
            bytes32 keyCounterOdd = _keyOdds( _marketId
                                            , _runnerId
                                            , _odd
                                            , counterBetType ); 
            
            //Si existen contraapuestas, tenemos que crear una nueva y matchearlas
            if ( placedBetByOdds[keyCounterOdd].length > 0 ){
                betId = _createAndMatch(_marketId, _runnerId, _odd, _betType, _stake, keyCounterOdd);
            }
            //Si no existe, tenemos que crear una nueva apuesta y dejarla como abierta
            //en los mapeos que nos permite hacer el matcheo de las apuetas
            else{                       
                betId = _createBet( _marketId
                                  , _runnerId
                                  , _odd
                                  , _betType
                                  , _stake
                                  , 0
                                  , BetStatus.OPEN );
                
                bytes32 keyNewOdd = _keyOdds( _marketId
                                            , _runnerId
                                            , _odd
                                            , _betType ); 

                placedBetByOdds[keyNewOdd].push(betId);            
            }
            //Agregamos la apuesta al histórico del usuario
            ownerToBetsIndex[msg.sender].push(betId);
            
            //Guardamos al apostador
            betIndexToOwner[betId] = msg.sender;

            //Agregamos la apuesta a la base de Mercados
            betsByMarket[_marketId].push(betId);  
            
            //Agregamos agregamos la lista de apuestas hechas
            bytes32 placedBetKey = _keyResolver(_marketId, _runnerId, _betType );
            placedBets[placedBetKey].push(betId);

            //Emitimos la orden
            emit PlacedBet(msg.sender, betId);
        }


        /**
        * @dev Crea y matchea una apuesta con una contraapuesta
        * @param _marketId Id en Laurasia
        * @param _runnerId Runner en Laurasia
        * @param _odd cuota. El valor decimal se transforma a uint. Si en al app el apostador ingresa 1.41, acá llega 141
        * @param _betType tipo de apuesta
        * @param _stake El monto que apostó el jugador
        * @param counterKeyOdds Es el Key del Map con las contraapuestas
        * @return betId - El ID de la apuesta
        */
        function _createAndMatch( uint128 _marketId, uint64 _runnerId, uint64 _odd, BetType _betType
                                 , uint _stake, bytes32 counterKeyOdds ) internal returns(uint){
            
            uint[] storage counterBets = placedBetByOdds[counterKeyOdds];
            uint betId = 0;
            bool finishPlaceBet = false;
            Bet memory newBet = Bet( _marketId
                                , _runnerId
                                , _odd
                                , _stake
                                , 0
                                , _betType
                                , BetStatus.OPEN );

            for(uint i = 0; i < counterBets.length && !finishPlaceBet; i++ ){
                //Omitimos los elementos 0, que se interpertan como eliminados
                if (counterBets[i] > 0){ 
                    //Obtenemos la contrapauesta
                    Bet storage counterBet = bets[counterBets[i]];
                    
                    //Si por alguna razón no se había eliminado la contraapuesta. la borramos
                    if ( counterBet.betStatus == BetStatus.CLOSED || 
                         counterBet.betStatus == BetStatus.FULL_MATCHED ){
                         delete counterBets[i];
                    }                    
                    //Trabajamos con las apuestas que están en estado Open o Parcialmente matcheadas
                    else {                        
                        //Calculamos el total del stake disponible de la contraapuesta
                        uint availableCounterStake = counterBet.stake - counterBet.matchedStake;    
                        uint availableStake = newBet.stake - newBet.matchedStake;
                        //Si el stake disponible es 0, tenemos que crear la nueva apuesta como abierta y 
                        //sin matchedStake. Debemos dejar la contraapuesta en full matched y no realizar el matcheo de
                        //la apuesta, además eliminar la contraapuesta de los betBtyOdds abiertos   
                        if (availableCounterStake == 0){
                            counterBet.betStatus = BetStatus.FULL_MATCHED;
                            delete counterBets[i];
                        }

                        else{
                            //Caso 1: Las apuestas matchean completamente porque el stake es el mismo. Ambas se deben cerrar,
                            //acutalizar el matchedStake y agregar el ID a la lista de matchedBets
                            if (availableStake == availableCounterStake){
                                counterBet.matchedStake += availableStake;
                                counterBet.betStatus = BetStatus.FULL_MATCHED;                              
                                delete counterBets[i];
                                
                                newBet.matchedStake += availableStake;
                                newBet.betStatus = BetStatus.FULL_MATCHED;
                                finishPlaceBet = true;
                                //En este caso no agregamos la apuesta a placedBetByOdds ya que es innecesaria
                            }

                            //Caso 2: El stake apuesta es superior al disponible de la contrapuesta. Se debe 
                            //acualizar el matchedStake y agrgear el ID a la lista de machtedBets de ambas
                            //apuestas, pero sólo se debe cerrar la contraApuesta
                            else if (availableStake > availableCounterStake){
                                counterBet.betStatus = BetStatus.FULL_MATCHED;
                                delete counterBets[i];
                                counterBet.matchedStake += availableCounterStake;

                                newBet.matchedStake += availableCounterStake;
                                newBet.betStatus = BetStatus.PARTIALLY_MATCHED;
                            }
                            //Caso 3. El stake de la apuesta es inferior al disponible en la contraapuesta. Se debe
                            //actualizar el matchedStake de ambos y agregar el ID a la lista de de matched de ambas
                            //apuestas, pero sólo se debe cerrar la apuesta.
                            else {
                                counterBet.matchedStake += availableStake;
                                counterBet.betStatus = BetStatus.PARTIALLY_MATCHED;
                                newBet.matchedStake += availableStake   ;
                                newBet.betStatus = BetStatus.FULL_MATCHED;
                                finishPlaceBet = true;
                            }
                        }   
                    }
                }
            }
            
            betId = bets.push(newBet) - 1;
            //La agregamos como un placed Odd                
            bytes32 keyNewOdd = _keyOdds( _marketId
                                        , _runnerId
                                        , _odd
                                        , _betType ); 

            placedBetByOdds[keyNewOdd].push(betId);   
         
            return betId;            
        }        

        /**
        * @dev Crea una nueva apuesta y la agrega a la base.
        * @param _marketId Id en Laurasia
        * @param _runnerId Runner en Laurasia
        * @param _odd cuota. El valor decimal se transforma a uint. Si se ingresa 1.41, llega 141
        * @param _betType tipo de apuesta
        * @param _stake El monto apostado por el jugador
        * @param _matchedStake El monto que se matcheo hasta el momento
        * @param _betStatus El estado de la apuesta
        * @return betId - El ID de la apuesta
        */
        function _createBet( uint128 _marketId, uint64 _runnerId, uint64 _odd
                        , BetType _betType, uint _stake, uint _matchedStake
                        , BetStatus _betStatus) internal returns(uint){
            //Creamos el el Bet y le asignamos un id Único
            uint betId = bets.push( Bet( _marketId
                                    , _runnerId
                                    , _odd
                                    , _stake
                                    , _matchedStake
                                    , _betType
                                    , _betStatus ) ) - 1;

            //Verificamos que no haya más de 2^128 apuestas
            require(betId == uint256(uint128(betId)), "Hubo buffer overflow en alta de apuesta");  
            return betId;    
        }

        /**
        * @dev Crea una clave para guardar los tipos de apuestas
        */
        function _keyResolver(uint128 _marketId, uint64 runnerId, BetType betType ) internal pure returns (bytes32) {
            bytes32 marketResultKey = keccak256(abi.encodePacked(_marketId, runnerId, betType));
            return marketResultKey;    
        }  

        /**
        * @dev Crea una clave para guardar los tipos de apuestas
        * @param _marketId El id del mercado
        * @param _runnerId El id del apostador
        * @param _odd La cuota de apuesta
         *@param _betType El tipo de puesta
        */
        function _keyOdds( uint128 _marketId
                         , uint64 _runnerId
                         , uint64 _odd
                         , BetType _betType ) internal pure returns (bytes32) {

            return keccak256(abi.encodePacked(_marketId, _runnerId, _odd, _betType));
        }  
    }