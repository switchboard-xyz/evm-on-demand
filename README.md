<div align="center">

![Switchboard Logo](https://github.com/switchboard-xyz/sbv2-core/raw/main/website/static/img/icons/switchboard/avatar.png)

# Switchboard On-Demand on EVM

> A collection of libraries and examples for interacting with Switchboard on EVM
> chains.

<!--
[![NPM Badge](https://img.shields.io/github/package-json/v/switchboard-xyz/sbv2-evm?color=red&filename=javascript%2Fevm.js%2Fpackage.json&label=%40switchboard-xyz%2Fevm.js&logo=npm)](https://www.npmjs.com/package/@switchboard-xyz/evm.js) -->

</div>

## NOTE: Switchboard On-Demand on EVM is currently an unaudited alpha. Use at your own risk.

Documentation and examples for using Switchboard On-Demand on Ethereum Virtual Machine (EVM) Networks. With Switchboard On-Demand, users can customize and create low-latency data feeds from any source.

## Current Deployments

- Core Mainnet: [0x33A5066f65f66161bEb3f827A3e40fce7d7A2e6C](https://scan.coredao.org/address/0x33A5066f65f66161bEb3f827A3e40fce7d7A2e6C)

- Core Testnet: [0x2f833D73bA1086F3E5CDE9e9a695783984636A76](https://scan.test.btcs.network/address/0x2f833D73bA1086F3E5CDE9e9a695783984636A76)

- Arbitrum Sepolia: [0xa2a0425fa3c5669d384f4e6c8068dfcf64485b3b](https://sepolia.arbiscan.io/address/0xa2a0425fa3c5669d384f4e6c8068dfcf64485b3b)

- Arbitrum One: [0xad9b8604b6b97187cde9e826cdeb7033c8c37198](https://arbiscan.io/address/0xad9b8604b6b97187cde9e826cdeb7033c8c37198)

- Morph Holesky: [0x3c1604DF82FDc873D289a47c6bb07AFA21f299e5](https://explorer-holesky.morphl2.io/address/0x3c1604DF82FDc873D289a47c6bb07AFA21f299e5)

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

There's a [Solidity-SDK](https://github.com/switchboard-xyz/evm-on-demand) that you can use to interact with the oracle contract on-chain and leverage customized oracle data within your smart contracts. For querying oracle updates off-chain for on-chain submission, you can use the [Switchboard On-Demand Typescript-SDK](https://www.npmjs.com/package/@switchboard-xyz/on-demand).

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

### Solidity

The code below shows the flow for leveraging Switchboard feeds in Solidity.

```solidity
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ISwitchboard} from "@switchboard-xyz/on-demand-solidity/ISwitchboard.sol";
import {Structs} from "@switchboard-xyz/on-demand-solidity/structs/Structs.sol";

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
        // Get the existing Switchboard contract address on your preferred network from the Switchboard Docs
        switchboard = ISwitchboard(_switchboard);
        feedId = _feedId;
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
        switchboard.updateFeeds{value: fee}(updates);

        // Read the current value from a Switchboard feed.
        // This will fail if the feed doesn't have fresh updates ready (e.g. if the feed update failed)
        Structs.Update memory latestUpdate = switchboard.latestUpdate(feedId);

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
/* Example Using Crossbar (equivalent to index.ts) */
import * as ethers from "ethers";
import * as fs from "fs";
import { CrossbarClient } from "@switchboard-xyz/on-demand";

// Parse the response as JSON
const secret = fs.readFileSync(".secret", "utf-8");

// Create a provider
const provider = new ethers.JsonRpcProvider(
  "https://sepolia-rollup.arbitrum.io/rpc"
);

// Create a signer
const signerWithProvider = new ethers.Wallet(secret, provider);

// Target contract address
const exampleAddress = "0x4ED8171dB9eC85ee785e34AFBeFcAB539dbE2790";

// for tokens (this is the Human-Readable ABI format)
const abi = [
  "function getFeedData(bytes[] calldata updates) public payable",
  "function aggregatorId() public view returns (bytes32)",
];

const crossbar = new CrossbarClient(`https://crossbar.switchboard.xyz`);

// The Contract object
const exampleContract = new ethers.Contract(
  exampleAddress,
  abi,
  signerWithProvider
);

// Get the encoded updates
const { encoded } = await crossbar.fetchEVMResults({
  chainId: 421614,
  aggregatorIds: [await exampleContract.aggregatorId()],
});

// Update the contract + do some business logic
const tx = await exampleContract.getFeedData(encoded);

console.log(tx);

// Log the transaction hash
console.log("Transaction completed!");
```

# Running the Example

### Prerequisites

1. [Install Forge](https://book.getfoundry.sh/getting-started/installation)
2. [Install Bun](https://bun.sh/) for running the example typescript script
3. Pick an Aggregator ID, the Address from a Switchboard feed, and set it to the ENV variable `AGGREGATOR_ID` (e.g., `export AGGREGATOR_ID=0x...`). You can create a Feed or find one in the [Switchboard Explorer](https://beta.ondemand.switchboard.xyz/arbitrum/sepolia)
4. Setup an Arbitrum Sepolia Testnet wallet with funding

### Running the Example

To run the [example](/example), you will need to:

1. Clone the repository and navigate to Example:

```bash
git clone https://github.com/switchboard-xyz/evm-on-demand
cd evm-on-demand/example
```

2. Install the dependencies:

```bash
bun install
```

3. Run Forge install:

```bash
forge install
```

4. Set the test wallet's private key to ENV variable `PRIVATE_KEY` (e.g., `export PRIVATE_KEY=0x...`)

5. Run the script to deploy the example contract:

```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url https://sepolia-rollup.arbitrum.io/rpc --broadcast -vv
```

6. Set the Contract Address from the deployment to ENV variable `EXAMPLE_ADDRESS` (e.g., `export EXAMPLE_ADDRESS=0x...`)

7. Run the script to update the feed:

```bash
bun run index.ts
```
