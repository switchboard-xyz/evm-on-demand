import * as ethers from "ethers";
import * as fs from "fs";

interface FeedResponse {
  encoded: string[];
  results: OracleData[];
}

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
  recent_successes_if_failed: OracleData[];
  timestamp: number;
  result: number;
}

// Parse the response as JSON
const secret = fs.readFileSync(".secret", "utf-8");

// Create a provider
const provider = new ethers.JsonRpcProvider(
  // "https://rpc-holesky.morphl2.io"
  // "https://rpc.test.btcs.network"
  // "https://rpc.coredao.org"
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

// The Contract object
const exampleContract = new ethers.Contract(
  exampleAddress,
  abi,
  signerWithProvider
);

// Get the encoded updates
const results = await fetch(
  `https://crossbar.switchboard.xyz/updates/evm/421614/${await exampleContract.aggregatorId()}`
);

const { encoded }: FeedResponse = await results.json();

// Update the contract + do some business logic
const tx = await exampleContract.getFeedData(encoded);

console.log(tx);

// Log the transaction hash
console.log("Transaction completed!");
