//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import {Structs} from "../structs/Structs.sol";

// -- Oracle: an entity that can provide updates for feeds on a queue --
interface IOracleModule {
    /**
     * Get oracles associated with an address
     * @param queueId the queue
     * @param oracleAddress the address of the oracle
     * @return oracleAddress the oracle associated with the address
     */
    function getOracleByAddress(
        bytes32 queueId,
        address oracleAddress
    ) external view returns (Structs.Oracle memory);

    /**
     * Get an oracle
     * @param queueId The queueId associated with the oracle
     * @param oracleId The oracleId corresponding to the oracle
     * @return The oracle associated with the queueId and oracleId
     */
    function getOracle(
        bytes32 queueId,
        bytes32 oracleId
    ) external view returns (Structs.Oracle memory);

    /**
     * Get all oracles associated with a queue
     * @param queueId The queueId to get the oracles for
     * @return The oracles associated with the queue
     */
    function getAllOracles(
        bytes32 queueId
    ) external view returns (Structs.Oracle[] memory);
}
