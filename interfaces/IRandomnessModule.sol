//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import {Structs} from "../structs/Structs.sol";

// -- Randomness: enclave-sourced randomness from an oracle on a queue --
interface IRandomnessModule {
    event RandomnessRequested(
        bytes32 indexed randomnessId,
        address indexed authority,
        bytes32 queueId,
        uint64 minSettlementDelay,
        bytes32 indexed oracleId
    );

    event RandomnessRerolled(
        bytes32 indexed randomnessId,
        bytes32 indexed oracleId
    );

    /**
     * Request randomness from Switchboard from an Oracle on the queue
     * @param randomnessId The randomness id, which must be unique, is used to identify the randomness request
     * @param authority The authority (contract or EOA) that is in charge of providing the randomness
     * @param queueId The queue id that the randomness is associated with
     * @param minSettlementDelay The minimum delay before the randomness can be settled
     */
    function requestRandomness(
        bytes32 randomnessId,
        address authority,
        bytes32 queueId,
        uint64 minSettlementDelay
    ) external;

    /**
     * Request randomness from Switchboard from an Oracle on the queue
     * @param randomnessId The randomness id, which must be unique, is used to identify the randomness request
     * @param authority The authority (contract or EOA) that is in charge of providing the randomness
     * @param queueId The queue id that the randomness is associated with
     * @param minSettlementDelay The minimum delay before the randomness can be settled
     * @param oracleId The oracle id that must respond to the request
     */
    function requestRandomness(
        bytes32 randomnessId,
        address authority,
        bytes32 queueId,
        uint64 minSettlementDelay,
        bytes32 oracleId
    ) external;

    /**
     * Reroll randomness (to reuse existing randomness objects for new randomness requests)
     * @dev caller must be the authority for the randomness
     * @param randomnessId The randomness id
     */
    function rerollRandomness(bytes32 randomnessId) external;

    /**
     * Reroll randomness (to reuse existing randomness objects for new randomness requests)
     * @dev caller must be the authority for the randomness
     * @param randomnessId The randomness id
     * @param oracleId The oracle id to specifically reroll randomness from
     */
    function rerollRandomness(bytes32 randomnessId, bytes32 oracleId) external;

    /**
     * Get randomness by id
     * @param randomnessId The randomness id
     * @return randomness The randomness object
     */
    function getRandomness(
        bytes32 randomnessId
    ) external view returns (Structs.Randomness memory);
}
