import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config({ path: __dirname + "/.env" });

const apiKey = process.env.INFURA_API_KEY!;
const testnetNodeRpcUrl = process.env.TESTNET_NODE_RPC_URL!;
const mainnetNodeRpcUrl = process.env.MAINNET_NODE_RPC_URL!;
const walletPrivateKey = process.env.WALLET_PRIVATE_KEY!;

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `${testnetNodeRpcUrl}/${apiKey}`,
      accounts: [walletPrivateKey],
    },
    mainnet: {
      url: `${mainnetNodeRpcUrl}/${apiKey}`,
      accounts: [walletPrivateKey],
    },
  },
};

export default config;
