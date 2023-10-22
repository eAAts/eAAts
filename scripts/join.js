const {
    ethers
} = require("hardhat");

async function main() {
    // usdc = await ethers.getContractAt("TestToken", "0x7cC1C9B374b95AeeDA136192A08bFb7aFfE66C48");
    // tx = await usdc.approve("0xb6DEa39915680d127238564F746ecBa690edd2c2", ethers.constants.MaxUint256);
    // await tx.wait();
    // console.log(tx.hash);
    
    consumer = await ethers.getContractAt("eAAts", "0xb6DEa39915680d127238564F746ecBa690edd2c2");
    // tx = await consumer.joinOrder(1, "10" + "0".repeat(6), 5001);
    // // tx = await consumer.joinOrder(1, "10" + "0".repeat(6), 137);
    // await tx.wait();

    // console.log(tx.hash);

    console.log(await consumer.checkUpkeep("0x00"));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});