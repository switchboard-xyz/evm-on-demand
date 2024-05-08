# Switchboard On-Demand on EVM

## NOTICE: Switchboard On-Demand on EVM is currently an unaudited alpha. Use at your own risk.

Documentation and examples for using Switchboard On-Demand on Ethereum Virtual Machine (EVM) Networks. With Switchboard On-Demand, users can customize and create low-latency data feeds from any source.

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
    - [Forge (Optional)](#forge-optional)
- [Usage](#usage)
  - [Designing a Switchboard On-Demand Feed](#designing-a-switchboard-on-demand-feed)
  - [Solidity](#solidity)
  - [Getting the Encoded Updates](#getting-the-encoded-updates)

## Overview

Switchboard On-Demand is a decentralized oracle service that allows users to create custom data feeds on the Ethereum Virtual Machine (EVM) networks. Users can create a feed that specifies the data sources, aggregation method, and other parameters. Once the feed is created, users can query Switchboard oracles to resolve it, and verify the data on-chain. This is an example of a pull-based oracle service, where users can request custom data on-demand with low-latency and low gas cost.

## Getting Started

To get started with Switchboard On-Demand, you will need to install the Switchboard CLI and set up a Switchboard account. You can then create a Switchboard On-Demand job and query the oracle to get the data.

There's a [Solidity-SDK](https://TODO.com) that you can use to interact with the oracle contract on-chain and leverage customized oracle data within your smart contracts. For querying oracle updates off-chain for on-chain submission, you can use the [Switchboard On-Demand Typescript-SDK](https://TODO.com).

### Prerequisites

To use Switchboard On-Demand, you will need to have a basic understanding of Ethereum and smart contracts. For more on Switchboard's Architecture, see the [docs](https://switchboardxyz.gitbook.io/switchboard-on-demand/architecture-design) (EVM docs will be consolidated with main docs upon completion of audit).

### Installation

You can install the Switchboard On-Demand Solidity SDK by running:

```bash
npm install @switchboard-xyz/on-demand-solidity
```

And you can install the cross-chain Typescript SDK by running:

```bash
npm install @switchboard-xyz/on-demand
```

#### Forge (Optional)

If you're using Forge, add following to your remappings.txt file:
@switchboard-xyz/on-demand-solidity/=node_modules/@switchboard-xyz/on-demand-solidity

## Usage

### Designing a Switchboard On-Demand Feed

To design a Switchboard On-Demand feed, you can use the [On-Demand Builder](https://TODO.com). Switchboard Feeds are created by specifying data sources and aggregation methods in an [OracleJob](https://docs.switchboard.xyz/api/next/protos/OracleJob) format.

Here's an example of creating a feed for querying ETH/USDC on Binance:

```ts
import {
  createJob,
  simulateJob,
  getDevnetQueue,
} from "@switchboard-xyz/on-demand";

// ...

const job = createJob({
  tasks: [
    {
      httpTask: "https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDC",
    },
    {
      jsonParseTask: "$.price",
    },
  ],
});

const result = await simulateJob(job, await getDevnetQueue());
console.log(result); // Job's output price, feedId (derived from Job Definition, and Switchboard Queue ID)
```

### Solidity

The code below shows the flow for leveraging Switchboard feeds in Solidity.

```solidity
pragma solidity ^0.8.0;

import {ISwitchboard} from "@switchboard-xyz/on-demand-solidity/ISwitchboard.sol";
import {Structs} from "@@switchboard-xyz/on-demand-solidity/Structs.sol";

contract Example {
  ISwitchboard switchboard;

  // Every Switchboard Feed has a unique feed ID derived from the OracleJob definition and Switchboard Queue ID.
  bytes32 feedId;

  // If the transaction fee is not paid, the update will fail.
  error InsufficientFee(uint256 expected, uint256 received);

  // If the feed result is invalid, this error will be emitted.
  error InvalidResult(int128 result);

  // If the Switchboard update succeeds, this event will be emitted with the latest price.
  event FeedData(int128 price);

  /**
   * @param _switchboard The address of the Switchboard contract
   * @param _feedId The feed ID for the feed you want to query
   */
  constructor(address _switchboard, bytes32 _feedId) {
    // Initialize the target _switchboard
    // Get the existing Switchboard contract address on your preferred network from the Switchboard Docs at: https://TODO.com
    switchboard = ISwitchboard(_switchboard);
    feedId = _feedId; //
  }

  /**
   * getFeedData is a function that uses an encoded Switchboard update
   * If the update is successful, it will read the latest price from the feed
   * See below for fetching encoded updates (e.g., using the Switchboard Typescript SDK)
   * @param updates Encoded feed updates to update the contract with the latest result
   */
  function getFeedData(bytes[] calldata updates) public payable {


    // Get the fee for updating the feeds. If the transaction fee is not paid, the update will fail.
    uint256 fee = switchboard.getFee(updates);
    if (msg.value < fee) {
      revert InsufficientFee(fee, msg.value);
    }

    // Submit the updates to the Switchboard contract
    switchboard.updateFeeds{ value: fee }(updates);

    // Read the current value from a Switchboard feed.
    // This will fail if the feed doesn't have fresh updates ready (e.g. if the feed update failed)
    Structs.Update latestUpdate = switchboard.getLatestValue(feedId);

    // Get the latest feed result
    // This is encoded as decimal * 10^18 to avoid floating point issues
    // Some feeds require negative numbers, so results are int128's, but this example uses positive numbers
    int128 result = latestUpdate.result;

    // In this example, we revert if the result is negative
    if (result < 0) {
      revert InvalidResult(result);
    }

    // Emit the latest result from the feed
    emit FeedData(latestUpdate.result);
  }
}
```

This contract:

1. Sets the Switchboard contract address and feed ID in the constructor
2. Defines a function `getFeedData` that:
   - Checks if the transaction fee is paid, using `switchboard.getFee(bytes[] calldata updates)`
   - Submits the updates to the Switchboard contract using `switchboard.updateFeeds(bytes[] calldata updates)`
   - Reads the latest value from the feed using `switchboard.getLatestValue(bytes32 feedId)`
   - Emits the latest result from the feed

### Getting the Encoded Updates

To get the encoded updates for the feed, you can use the Switchboard Typescript SDK. Here's an example of how to get the encoded updates:

```ts
import {
  createJob,
  getDevnetQueue,
  fetchUpdateData,
} from "@switchboard-xyz/on-demand";

// Create a Switchboard On-Demand job
const job = createJob({
  tasks: [
    {
      httpTask: "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT",
    },
    {
      jsonParseTask: "$.price",
    },
  ],
});

// Get the latest update data for the feed
const update = await getFeedUpdateData({
  // Within feeds you can have multiple jobs, the final result will be the median of all jobs
  jobs: [job],
  // The Switchboard Queue to use
  queue: await getDevnetQueue(),
  // The Switchboard Contract Address, which can be found at https://TODO.com for your preferred network
  contract: "0x1234567890123456789012345678901234567890",
});

// `bytes32` string of the feed ID, ex: 0x0f762b759dca5b4421fba1cf6fba452cdf76fb9cc6d8183722a78358a8339d10
const feedId = update.feedId;

// `bytes` string of the encoded update for the feed which can be used in your contract
const update = update.encoded;
```

See [the examples](https://TODO.com) for an end-to-end implementation.
