const {
    ethers
} = require("hardhat");

async function main() {
    consumer = await ethers.getContractAt("eAAts", "0xb6DEa39915680d127238564F746ecBa690edd2c2");
    tx = await consumer.createOrder(1, 0);

    console.log(tx.hash);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});