const {
  ethers
} = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  let consumer;

  const FunctionsConsumer = await ethers.getContractFactory("FunctionsConsumer");
  consumer = await FunctionsConsumer.deploy("0xdc2AAF042Aeff2E68B3e8E33F19e4B9fA7C73F10");
  await consumer.deployed();

  console.log("FunctionsConsumer address : ", consumer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});