//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import {Structs} from "./Structs.sol";

interface ISwitchboard {
    // -- Switchboard: the main contract for the Switchboard protocol --

    /**
     * Get the latest Update struct for a feed
     * @dev Intended to be called within the same transaction as a feed update for the most up-to-date data.
     * @dev Reverts if the feed does not exist
     * @dev Reverts if the feed does not have a valid update within queue (or aggregator's) tolerated delta
     * @dev Reverts if the feed does not have the minimum number of valid responses
     * @param feedId The identifier for the feed to get the latest update for
     * @return Update The latest update for the given feed
     */
    function latestUpdate(
        bytes32 feedId
    ) external view returns (Structs.Update memory);

    /**
     * Get the latest Update struct for a feed
     * @dev Intended to be called within the same transaction as a feed update for the most up-to-date data.
     * @dev Reverts if the feed does not exist
     * @dev Reverts if the feed does not have a valid update within queue (or aggregator's) tolerated delta
     * @dev Reverts if the feed does not have the minimum number of valid responses
     * @param feedId The identifier for the feed to get the latest update for
     * @param toleratedDelta The maximum timestamp delta for a valid feed result
     * @return Update The latest update for the given feed
     */
    function latestUpdate(
        bytes32 feedId,
        uint256 toleratedDelta
    ) external view returns (Structs.Update memory);

    /**
     * Get the fee in wei for submitting a set of updates
     * @param updates Encoded switchboard update(s) with signatures
     * @return uint256 The fee in wei for submitting the updates
     */
    function getFee(bytes[] calldata updates) external view returns (uint256);

    /**
     * Update feeds with new oracle results
     * @dev reverts if the queue's fee is not paid
     * @dev reverts if the timestamp is out of valid range (optional flow for timestamp-sequenced updates)
     * @param updates Encoded switchboard update(s) with signatures
     */
    function updateFeeds(bytes[] calldata updates) external payable;

    // -- Feeds: a structured format for external information, such as price or event outcomes, sourced by oracles for use within Switchboard --

    /**
     * Get a feed
     * @param feedId The feedId to get
     * @return The feed associated with the feedId and its latest updates
     */
    function getFeed(
        bytes32 feedId
    ) external view returns (Structs.Feed memory, Structs.Update[] memory);

    /**
     * Get all feeds
     * @return All existing feeds and their latest updates
     */
    function getAllFeeds()
        external
        view
        returns (Structs.Feed[] memory, Structs.Update[][] memory);

    /**
     * Get the results for a feed
     * @param feedId The feedId to get the results for
     * @return The latest results for the feed
     */
    function getFeedResults(
        bytes32 feedId
    ) external view returns (Structs.Update[] memory);

    // -- Aggregators: an abstraction over feeds to allow for reconfiguration --

    /**
     * Create a new aggregator
     * @param aggregator The aggregator to create
     */
    function createAggregator(Structs.Aggregator calldata aggregator) external;

    /**
     * Set the config for an aggregator
     * @dev Only the authority of the aggregator can set the config
     * @param aggregatorId The aggregatorId to set the config for
     * @param name The name of the aggregator
     * @param toleratedDelta The maximum staleness seconds for a valid feed result (or seconds if the queue has a time feed)
     * @param feedId The feedId associated with the aggregator
     */
    function setAggregatorConfig(
        bytes32 aggregatorId,
        string memory name,
        uint256 toleratedDelta,
        bytes32 feedId
    ) external;

    /**
     * Set the authority for an aggregator
     * @dev Only the authority of the aggregator can set a new authority
     * @param aggregatorId The aggregatorId to set the authority for
     * @param authority The new authority to set for the aggregator
     */
    function setAggregatorAuthority(
        bytes32 aggregatorId,
        address authority
    ) external;

    /**
     * The aggregator to fetch
     * @param aggregatorId The aggregatorId to get
     * @return The aggregator associated with the aggregatorId and its latest updates
     */
    function getAggregator(
        bytes32 aggregatorId
    )
        external
        view
        returns (Structs.Aggregator memory, Structs.Update[] memory);

    /**
     * Get all aggregators
     * @return All existing aggregators and their latest updates
     */
    function getAllAggregators()
        external
        view
        returns (Structs.Aggregator[] memory, Structs.Update[][] memory);

    // -- Oracle: an entity that can provide updates for feeds on a queue --

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

    // -- Queues: switchboard subnets (each with its own set of oracles) --

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
     * @param toleratedTimestampDelta default maximum timestamp delta for a valid feed result
     * @param resultsMaxSize maximum size of the results array for feeds
     * @param oracleValidityLength length of time an oracle is valid for
     */
    function setQueueConfig(
        bytes32 queueId,
        string memory name,
        uint256 fee,
        uint8 minAttestations,
        uint256 toleratedTimestampDelta,
        uint8 resultsMaxSize,
        uint256 oracleValidityLength
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
     * Set the queue time feed
     * @dev Only the authority of the queue can set the time feed
     * @dev A timestamp update (discriminator=3) must be sent as the first update, followed by other feed updates
     * @param queueId The queueId to set the time feed for
     * @param timeFeed The time feed to set for the queue
     * @param toleratedTimestampDelta The maximum delta between the timestamp of the feed update
     */
    function setQueueTimeFeed(
        bytes32 queueId,
        bytes32 timeFeed,
        uint256 toleratedTimestampDelta
    ) external;

    /**
     * Get a queue
     * @param queueId The queueId to get
     * @return The queue associated with the queueId
     */
    function getQueue(
        bytes32 queueId
    ) external view returns (Structs.Queue memory);

    /**
     * Get all queues
     * @return All existing queues
     */
    function getAllQueues() external view returns (Structs.Queue[] memory);

    /**
     * Initialize a queue with a time feed (and create aggregator if specified)
     * @param queueId The queueId to initialize
     * @param timeFeed The time feed to initialize
     * @param aggregatorId The aggregatorId to initialize
     * @param toleratedTimestampDelta The maximum delta between the timestamp of the block and the timestamp of the feed update
     */
    function intializeQueueTimeFeed(
        bytes32 queueId,
        bytes32 timeFeed,
        bytes32 aggregatorId,
        uint256 toleratedTimestampDelta
    ) external;

    /**
     * Initialize a time feed for a queue
     * @param queueId Queue to initialize the time feed for
     * @param timeFeed Time feed to initialize
     */
    function initializeTimeFeed(
        bytes32 queueId,
        bytes32 timeFeed
    ) external returns (bytes32);
}
