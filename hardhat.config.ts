import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.16",
  networks: {
    hardhat: {
      accounts: {
        mnemonic: "exhaust short galaxy address hire cage picture water motion hold bid profit"
      }
    }
  }
};

export default config;
