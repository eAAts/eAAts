// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  let eaats, testToken, testAAFactory, testAA;
  let deployer, addr1, addr2, addr3;

  const TestToken = await ethers.getContractFactory("TestToken");
  testToken = await TestToken.deploy();
  await testToken.deployed();

  console.log("testToken address : ", testToken.address);

  const TestAAFactory = await ethers.getContractFactory("TestAAFactory");
  testAAFactory = await TestAAFactory.deploy();
  await testAAFactory.deployed();

  console.log("testAAFactory address : ", testAAFactory.address);

  const eAAts = await ethers.getContractFactory("eAAts");
  const deliveryFee = ethers.utils.parseEther("3");
  eaats = await eAAts.deploy(testAAFactory.address, testToken.address, deliveryFee);
  await eaats.deployed();

  console.log("eaats address : ", eaats.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
