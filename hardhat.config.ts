import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.16",
  networks: {
    hardhat: {
      accounts: {
        mnemonic: "exhaust short galaxy address hire cage picture water motion hold bid profit"
      }
    },
    goerli: {
      url: `https://goerli.infura.io/v3/1d1afdfaea454548a5fed4a5030eca65`,
      accounts: ['40ec24ee8186378bc08c39f13aa6cf8e324c0307f6edfd52273b714f2d4c1b28'],
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: "J5WI1PCXIIPU8NK93CHKB1NGCIY7T7FKVD"
  }
};

export default config;
