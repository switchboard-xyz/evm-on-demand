//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import {Structs} from "../structs/Structs.sol";

// -- Queues: switchboard subnets (each with its own set of oracles) --
interface IQueueModule {
    event QueueCreated(bytes32 queueId, address authority);
    event QueueConfigSet(
        bytes32 queueId,
        string name,
        uint256 fee,
        uint8 minAttestations,
        uint256 toleratedTimestampDelta,
        uint8 resultsMaxSize,
        uint256 oracleValidityLength,
        uint256 toleratedBlocksStaleness
    );
    event QueueAuthoritySet(bytes32 queueId, address authority);
    event QueueMrEnclaveAdded(bytes32 queueId, bytes32 mrEnclave);
    event QueueMrEnclaveRemoved(bytes32 queueId, bytes32 mrEnclave);
    event QueueOraclesOverridden(bytes32 queueId);

    /**
     * Create a new queue
     * @param queue The queue to create
     * @param oracles The initial set of oracles associated with the queue
     */
    function createQueue(
        Structs.Queue calldata queue,
        Structs.Oracle[] calldata oracles
    ) external;

    /**
     * Set the config for a queue
     * @dev Only the authority of the queue can set the config
     * @param queueId the queueId to set the config for
     * @param name name of the queue
     * @param fee fee required to submit an update to the queue
     * @param minAttestations minimum number of attestations required for adding an oracle the queue
     * @param toleratedTimestampDelta default maximum staleness blocks for a valid feed result
     * @param resultsMaxSize maximum size of the results array for feeds
     * @param oracleValidityLength length of time an oracle is valid for
     * @param toleratedBlocksStaleness The number of blocks a timestamp is allowed to be stale
     */
    function setQueueConfig(
        bytes32 queueId,
        string memory name,
        uint256 fee,
        uint8 minAttestations,
        uint256 toleratedTimestampDelta,
        uint8 resultsMaxSize,
        uint256 oracleValidityLength,
        uint256 toleratedBlocksStaleness
    ) external;

    /**
     * Set the authority for a queue
     * @dev Only the authority of the queue can set a new authority
     * @param queueId The queueId to set the authority for
     * @param authority The new authority to set for the queue
     */
    function setQueueAuthority(bytes32 queueId, address authority) external;

    /**
     * Add an enclave measurement to a queue
     * @dev Only the authority of the queue can set the mrEnclave
     * @param queueId The queueId to set the mrEnclave for
     * @param mrEnclave The mrEnclave to set for the queue
     */
    function addQueueMrEnclave(bytes32 queueId, bytes32 mrEnclave) external;

    /**
     * Remove an enclave measurement from a queue
     * @dev Only the authority of the queue can remove the mrEnclave
     * @param queueId The queueId to remove the mrEnclave from
     * @param mrEnclave The mrEnclave to remove
     */
    function removeQueueMrEnclave(bytes32 queueId, bytes32 mrEnclave) external;

    /**
     * Get the mrEnclaves associated with a queue
     * @param queueId The queueId to get the mrEnclaves for
     * @return The mrEnclaves associated with the queue
     */
    function getQueueMrEnclaves(
        bytes32 queueId
    ) external view returns (bytes32[] memory);

    /**
     * Set the oracle queue manually (override the oracles array)
     * @dev Should only be dao controlled
     * @param queueId The queueId to set the oracles for
     * @param oracles The oracles to set for the queue
     */
    function queueOverride(
        bytes32 queueId,
        bytes32[] calldata mrEnclaves,
        Structs.Oracle[] calldata oracles
    ) external;

    /**
     * Get a queue
     * @param queueId The queueId to get
     */
    function getQueue(
        bytes32 queueId
    ) external view returns (Structs.Queue memory);

    /**
     * Get all queues
     * @return The queues associated with the queueId
     */
    function getAllQueues() external view returns (Structs.Queue[] memory);
}
