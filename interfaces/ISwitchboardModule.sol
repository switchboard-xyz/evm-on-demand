//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import {Structs} from "../structs/Structs.sol";

// -- Switchboard: the main contract for the Switchboard protocol  --
interface ISwitchboardModule {
    event FeedUpdate(
        bytes32 indexed feedId,
        bytes32 indexed oracleId,
        uint256 timestamp,
        int128 result
    );
    event OracleAdded(
        bytes32 indexed queueId,
        bytes32 indexed oracleId,
        address indexed oracleAddress
    );
    event OracleRemoved(bytes32 indexed queueId, bytes32 indexed oracleId);
    event RandomnessSettled(
        bytes32 indexed randomnessId,
        bytes32 indexed oracleId,
        uint256 timestamp,
        uint256 result
    );

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
     * Calculate
     * @param aggregatorId The feed identifier to calculate the current result for
     * @return CurrentResult The current result for the given feed, a struct containing stats and the result
     */
    function findCurrentResult(
        bytes32 aggregatorId
    ) external view returns (Structs.CurrentResult memory);

    /**
     * Get the fee in wei for submitting a set of updates
     * @param updates Encoded switchboard update(s) with signatures
     * @return uint256 The fee in wei for submitting the updates
     */
    function getFee(bytes[] calldata updates) external view returns (uint256);

    /**
     * Update feeds with new oracle results
     * @dev reverts if the queue's fee is not paid
     * @dev reverts if the blockhash is invalid (i.e. the block is in the future)
     * @dev reverts if the timestamp is out of valid range (optional flow for timestamp-sequenced updates)
     * @param updates Encoded switchboard update(s) with signatures
     */
    function updateFeeds(bytes[] calldata updates) external payable;
}
