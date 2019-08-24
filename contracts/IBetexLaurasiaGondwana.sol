pragma solidity 0.5.10;

/**
 * @dev Es la interfaz entre BetexLaursia y Gondwana. Permite registrar y
 * y consultar eventos deportivos y resultados.
 */
interface IBetexMobileGondwana {

    /**
     * @dev Abre un mercado determinado con n competidores o runners. Por control interno.
     * @param _eventId Id el evento de Laurasia
     * @param _marketId ID del mercado de Laurasia
     * @param _marketRunnerHashes Array con los Hashes de los competidores por market. Máximo 3 elementos de sha3 (marketId + runnerId)
     */
    function openMarket(uint256 _eventId, uint256 _marketId, bytes32[] calldata _marketRunnerHashes) external;

    /**
     * @dev Suspende un mercado determinado, por ejemplo cuando se anula un evento.
     * @param _marketId ID del mercado de Laurasia
     */
    function suspendMarket(uint256 _marketId) external;

    /**
     * @dev Cierra un mercado determinado. Significa que ya no se aceptan más apuestas
     * @param _marketId ID del mercado de Laurasia
     */
    function closeMarket(uint256 _marketId) external;

    /**
     * @dev Resuevle un mercado determinado. Significa que se determina el ganador
     * @param _marketId ID del mercado de Laurasia
     * @param _winnerMarketRunnerHash hash del competidor ganador. sha3 (marketId + runnerId)
     */
    function resolveMarket(uint256 _marketId, bytes32 _winnerMarketRunnerHash) external;

    /**
     * @dev Verifica si un competidor de un mercado determinado es el ganador de un evento
     * @param _marketRunnerHash Hash del competidor. sha3 (marketId + runnerId)
     * @return true si es ganador, false de lo contrario
     */
    function isWinner(bytes32 _marketRunnerHash) external view returns(bool);

    /**
     * @dev Verifica si existe un competidor de un mercado determinado
     * @param _marketRunnerHash Hash del competidor. sha3 (marketId + runnerId)
     * @return true si existe, false de lo contrario
     */
    function marketRunnerExists(bytes32 _marketRunnerHash) external view returns(bool);

    /**
     * @dev Cierra un evento determinado. Significa que no se pueden aceptar apuestas a ninguno
     * de sus mercados. Tipicamente los eventos de Boxeo y MMA solo se pueden apostar hasta 15 minutos
     * antes del inicio programado
     * @param _eventId ID del evento de Laurasia
     */
    function closeEvent(uint256 _eventId) external;

    /**
     * @dev Suspende un evento determinado por algún factor externo, por ejemplo la suspeción
     * de un partido de fútbol o un combate deportivo.
     * @param _eventId ID del mercado de Laurasia
     */
    function suspendEvent(uint256 _eventId) external;
}