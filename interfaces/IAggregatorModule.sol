//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import {Structs} from "../structs/Structs.sol";

// -- Aggregators: an abstraction over feeds to allow for reconfiguration --
interface IAggregatorModule {
    event AggregatorCreated(
        bytes32 indexed aggregatorId,
        bytes32 indexed feedId,
        address authority
    );
    event AggregatorConfigured(
        bytes32 indexed aggregatorId,
        string name,
        uint256 toleratedDelta,
        bytes32 cid,
        uint64 maxVariance,
        uint32 minResponses
    );
    event AggregatorAuthoritySet(
        bytes32 indexed aggregatorId,
        address indexed authority
    );

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
     * @param toleratedDelta The maximum staleness blocks for a valid feed result (or seconds if the queue has a time feed)
     * @param cid The content id (IPFS cid for example) for the feed
     * @param feedId The feedId associated with the aggregator
     * @param maxVariance The maximum variance allowed for a feed result
     * @param minResponses The minimum number of responses required for a valid feed result
     * @param minSamples The minimum number of samples to take for a feed result
     * @param maxStaleness The maximum number of seconds staleness for an update to be valid
     */
    function setAggregatorConfig(
        bytes32 aggregatorId,
        string memory name,
        uint256 toleratedDelta,
        bytes32 cid,
        bytes32 feedId,
        uint64 maxVariance,
        uint32 minResponses,
        uint8 minSamples,
        uint256 maxStaleness
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
     */
    function getAggregator(
        bytes32 aggregatorId
    )
        external
        view
        returns (Structs.Aggregator memory, Structs.Update[] memory);

    /**
     * Get all aggregators
     */
    function getAllAggregators()
        external
        view
        returns (Structs.Aggregator[] memory, Structs.Update[][] memory);

    /**
     * Get the results for a feed
     * @param feedId The feedId to get the results for
     * @return The results for the feed
     */
    function getAggregatorResults(
        bytes32 feedId
    ) external view returns (Structs.Update[] memory);
}
