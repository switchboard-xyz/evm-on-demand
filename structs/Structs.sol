//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

contract Structs {
    /**
     * An update to a feed
     * @param oracleId The publisher of the update
     * @param result The result of the update
     * @param timestamp The timestamp of the update
     */
    struct Update {
        bytes32 oracleId;
        int128 result;
        uint256 timestamp;
    }

    /**
     * The current result for a feed
     * @param result The result of the feed
     * @param minTimestamp The minimum timestamp of the feed
     * @param maxTimestamp The maximum timestamp of the feed
     * @param minResult The minimum result of the feed
     * @param maxResult The maximum result of the feed
     * @param stdev The standard deviation of the feed
     * @param range The range of the feed
     * @param mean The mean of the feed
     */
    struct CurrentResult {
        int128 result;
        uint256 minTimestamp;
        uint256 maxTimestamp;
        int128 minResult;
        int128 maxResult;
        int128 stdev;
        int128 range;
        int128 mean;
    }

    /**
     * Results for a feed
     * @param idx The index of the feed
     * @param updates The updates for the feed
     */
    struct Results {
        uint256 idx;
        Update[] updates;
    }

    /**
     * An abstraction over feed allowing for UI to display the feed in a more human readable way and reconfiguration of sources.
     * Reading from this struct should be atomic (same tx as the write).
     * @param aggregatorId The aggregator id
     * @param authority The authority of the feed
     * @param name The name of the feed
     * @param queueId The queue id associated with the feed
     * @param toleratedDelta The maximum blocks staleness
     * @param cid The content id (IPFS cid for example) for the feed
     * @param feedHash The feed associated with the aggregator
     * @param createdAt The time the feed was created
     * @param maxVariance The maximum variance allowed for a feed result
     * @param minResponses The minimum number of responses required for a valid feed result
     * @param minSamples The minimum number of samples to take for a feed result
     * @param maxStaleness The maximum number of seconds staleness for an update to be valid
     */
    struct Aggregator {
        bytes32 aggregatorId;
        address authority;
        string name;
        bytes32 queueId;
        uint256 toleratedDelta;
        bytes32 cid;
        bytes32 feedHash;
        uint256 createdAt;
        uint64 maxVariance;
        uint32 minResponses;
        uint8 minSamples;
        uint256 maxStaleness;
    }

    /**
     * Queue / Switchboard Subnet
     * @param queueId The queue id
     * @param authority The authority of the queue
     * @param name The name of the queue
     * @param fee The fee required to submit an update to the queue
     * @param feeRecipient The recipient of the fee (OPTIONAL - if unset the oracle is the recipient)
     * @param minAttestations size * (1 / minAttestations) + 1 is the minimum number of oracles required to attest to a registration
     * @param toleratedTimestampDelta The default maximum staleness for a valid feed result
     * @param resultsMaxSize The maximum size of the results array
     * @param oracleValidityLength The length of time an oracle is valid for
     * @param mrEnclaves The enclave measurements allowed by the queue
     * @param oracles The oracles associated with the queue
     * @param toleratedBlocksStaleness The number of blocks a timestamp is allowed to be stale
     * @param lastQueueOverride The last time the queue was overridden
     * @param guardianQueueId The guardian queue id
     */
    struct Queue {
        bytes32 queueId;
        address authority;
        string name;
        uint256 fee;
        address feeRecipient;
        uint64 minAttestations;
        uint256 toleratedTimestampDelta;
        uint8 resultsMaxSize;
        uint256 oracleValidityLength;
        bytes32[] mrEnclaves;
        bytes32[] oracles;
        uint256 toleratedBlocksStaleness;
        uint256 lastQueueOverride;
        bytes32 guardianQueueId;
    }

    /**
     * Oracle - A more dense version of the oracle
     * @param authority the oracle's enclave secp key
     * @param owner the owner of the oracle
     * @param oracleId the oracle's id (hexified pubkey from solana)
     * @param queueId the queue that the oracle belongs to
     * @param mrEnclave the oracle's enclave measurement
     * @param expirationTime the time the oracle expires
     * @param feesOwed the fees owed to the oracle
     */
    struct Oracle {
        address authority;
        address owner;
        bytes32 oracleId;
        bytes32 queueId;
        bytes32 mrEnclave;
        uint256 expirationTime;
        uint256 feesOwed;
    }

    /**
     * Pending Oracle Registration
     * @param oracle The oracle to be registered
     * @param attestingOracle The oracle attesting to the registration
     */
    struct OracleAttestation {
        address oracleAuthority;
        bytes32 oracleId;
        bytes32 attestingOracle;
        uint256 timestamp;
        bytes32 mrEnclave;
    }

    /**
     * Randomness - a message resolving randomness
     * @param randId The randomness id
     * @param queueId The queue id
     * @param createdAt The time the randomness was created
     * @param authority The authority of the randomness
     * @param rollTimestamp The timestamp of the latest roll
     * @param minSettlementDelay The minimum settlement delay seconds
     * @param result The value of the randomness (uint256)
     */
    struct Randomness {
        bytes32 randId;
        bytes32 queueId;
        uint256 createdAt;
        address authority;
        uint256 rollTimestamp;
        uint64 minSettlementDelay;
        RandomnessResult result;
    }

    /**
     * Randomness Result
     * @param oracleId The oracle id
     * @param oracleAuthority The authority of the oracle that provided the randomness
     * @param value The value of the randomness
     * @param settledAt The time the randomness was settled
     */
    struct RandomnessResult {
        bytes32 oracleId;
        address oracleAuthority;
        uint256 value;
        uint256 settledAt;
    }

    /**
     * Attestations
     * @param list The list of pending attestations
     */
    struct Attestations {
        OracleAttestation[] list;
    }
}
