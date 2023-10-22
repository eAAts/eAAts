require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [{
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          },
          viaIR: true,
        }
      },
    ],
  },
  networks: {
    hardhat: {
      forking: {
        url: "https://polygon-mainnet.infura.io/v3/" + process.env.INFURA_KEY,
      },
    },
    mumbai: {
      url: "https://polygon-mumbai.infura.io/v3/" + process.env.INFURA_KEY,
      accounts: [PRIVATE_KEY, ],
    },
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: [PRIVATE_KEY, ],
    },
  },
  etherscan: {
    // apiKey: process.env.POLYGONSCAN_API_KEY,
  },
};