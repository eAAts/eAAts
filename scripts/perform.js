const {
  ethers
} = require("hardhat");

async function main() {
  const eAAts = await ethers.getContractAt("eAAts", "0xb6DEa39915680d127238564F746ecBa690edd2c2");
  await eAAts.performUpkeep("0x000000000000000000000000ca1e82cf1174c4765a1cff04eb30925adf4a50a30000000000000000000000007cc1c9b374b95aeeda136192a08bfb7affe66c480000000000000000000000000000000000000000000000000000000000989680");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});