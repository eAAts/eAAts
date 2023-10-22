const {
  ethers
} = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  let eaats;

  const feeData = await ethers.provider.getFeeData();

  const eAAts = await ethers.getContractFactory("eAAts");
  const consumerAddress = "0xB34715F7229C77c8c8aA841cf728190D5eb11961";
  const source = fs
    .readFileSync(path.resolve(__dirname, "source.js"))
    .toString();
  const deliveryFee = "3"+"0".repeat(6);
  eaats = await eAAts.deploy(consumerAddress, 25, source, "0x7cC1C9B374b95AeeDA136192A08bFb7aFfE66C48", deliveryFee);
  await eaats.deployed();

  console.log("eaats address : ", eaats.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});