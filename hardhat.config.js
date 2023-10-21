require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: "https://polygon-mumbai.infura.io/v3/" + process.env.INFURA_KEY,
      },
    },
    mumbai: {
      url: "https://polygon-mumbai.infura.io/v3/" + process.env.INFURA_KEY,
      accounts: [PRIVATE_KEY, ],
    },
  },
  etherscan: {
    // apiKey: process.env.POLYGONSCAN_API_KEY,
  },
};