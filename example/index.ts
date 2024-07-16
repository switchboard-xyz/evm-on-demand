import * as ethers from "ethers";
import * as fs from "fs";

interface OracleData {
  oracle_pubkey: string;
  queue_pubkey: string;
  oracle_signing_pubkey: string;
  feed_hash: string;
  recent_hash: string;
  failure_error: string;
  success_value: string;
  msg: string;
  signature: string;
  recovery_id: number;
  recent_successes_if_failed: any[];
  timestamp: number;
  result: number;
}

interface FeedResponse {
  encoded: string[];
  results: OracleData[];
}

// Create a Switchboard On-Demand job
const results = await fetch(
  "https://crossbar.switchboard.xyz/updates/evm/1116/<YOUR_FEED_ID>"
);

const { encoded }: FeedResponse = await results.json();

// Parse the response as JSON
const secret = fs.readFileSync(".secret", "utf-8");

// Create a provider
const provider = new ethers.JsonRpcProvider(
  // "https://arb-sepolia.g.alchemy.com/v2/_R42-0YT99H8TzoENEZgSDHsDTiBOUPb"
  // "https://rpc-holesky.morphl2.io"
  "https://rpc.test.btcs.network"
  // "https://rpc.coredao.org"
);

// Create a signer
const signerWithProvider = new ethers.Wallet(secret, provider);

// Target contract address
const exampleAddress = "<YOUR_EXAMPLE_CONTRACT>";

// for tokens (this is the Human-Readable ABI format)
const abi = ["function getFeedData(bytes[] calldata updates) public payable"];

// The Contract object
const exampleContract = new ethers.Contract(
  exampleAddress,
  abi,
  signerWithProvider
);

// Update the contract
const tx = await exampleContract.getFeedData(encoded);

// Wait for the transaction to settle
await tx.wait();

// Log the transaction hash
console.log("Transaction mined!");
