//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Structs {
    /**
     * An update to a feed
     * @param oracleId The publisher of the update
     * @param result The result of the update
     * @param blockNumber The block number of the update / (will be 0 if not a block update)
     * @param timestamp The timestamp of the update
     */
    struct Update {
        bytes32 oracleId;
        int128 result;
        uint256 blockNumber;
        uint256 timestamp;
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
     * A feed which receives updates from oracles
     * @param feedId The feed id (also the feed hash)
     * @param queue The queue the feed is associated with
     * @param maxVariance The maximum variance allowed for the feed
     * @param minResponses The minimum number of responses required for the feed
     */
    struct Feed {
        bytes32 feedId;
        bytes32 queueId;
        uint64 maxVariance;
        uint32 minResponses;
    }

    /**
     * An abstraction over feed allowing for UI to display the feed in a more human readable way and reconfiguration of sources.
     * Reading from this struct should be atomic (same tx as the write).
     * @param authority The authority of the feed
     * @param name The name of the feed
     * @param queueId The queue id associated with the feed
     * @param toleratedDelta The maximum blocks staleness (or seconds staleness if timestamp feed enabled by queue) for a valid feed result
     * @param feedId The feed associated with the aggregator
     */
    struct Aggregator {
        bytes32 aggregatorId;
        address authority;
        string name;
        uint256 toleratedDelta;
        bytes32 feedId;
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
     * @param size The size of the oracles array
     * @param lastQueueOverride The last time the queue was overridden
     * @param guardianQueueId The guardian queue id (OPTIONAL - if unset the queue is not a guardian queue)
     * @param timeFeed The time feed associated with the queue (OPTIONAL - if unset the will expect ordinary native blockhash updates)
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
        uint256 size;
        uint256 lastQueueOverride;
        bytes32 guardianQueueId;
        bytes32 timeFeed;
    }

    /**
     * Oracle - An oracle that can submit updates to feeds.
     * @dev Oracles are registered to a queue
     * @dev An Oracle can have instances on many queues
     * @param authority The authority of the oracle (derived from its public key)
     * @param oracleId The oracle pubkey
     * @param queueId The queue id associated with the oracle
     * @param ed25519PublicKey The ed25519 public key of the oracle
     * @param mrEnclave The mrEnclave of the oracle
     * @param expirationTime The time the oracle expires
     * @param secp256k1PublicKey The secp256k1 public key of the oracle
     */
    struct Oracle {
        address authority;
        bytes32 oracleId;
        bytes32 queueId;
        bytes32 ed25519PublicKey;
        bytes32 mrEnclave;
        uint256 expirationTime;
        bytes secp256k1PublicKey;
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
        uint256 blockNumber;
        bytes32 mrEnclave;
    }

    /**
     * Attestations
     * @param size The size of the attestations list
     * @param list The list of pending attestations
     */
    struct Attestations {
        uint256 size;
        OracleAttestation[] list;
    }
}
