const {
    ethers
} = require("hardhat");
const fs = require("fs");
const path = require("path");

const source = fs
    .readFileSync(path.resolve(__dirname, "source.js"))
    .toString();
const donId = "fun-polygon-mainnet-1";

async function main() {
    let consumer;

    console.log(ethers.utils.formatBytes32String(donId));
    // const FunctionsConsumer = await ethers.getContractFactory("FunctionsConsumer");
    // consumer = await FunctionsConsumer.deploy("0x6E2dc0F9DB014aE19888F539E59285D2Ea04244C");
    // await consumer.deployed();

    // console.log("FunctionsConsumer address : ", consumer.address);

    // await consumer.sendRequest(
    //     source, // source
    //     "0x", // user hosted secrets - encryptedSecretsUrls - empty in this example
    //     0, // don hosted secrets - slot ID - empty in this example
    //     0, // don hosted secrets - version - empty in this example
    //     ["1", "1", "1"],
    //     [], // bytesArgs - arguments can be encoded off-chain to bytes.
    //     466,
    //     300000,
    //     ethers.utils.formatBytes32String(donId) // jobId is bytes32 representation of donId
    // );

    let eaats, testToken;

    // const TestToken = await ethers.getContractFactory("TestToken");
    // testToken = await TestToken.deploy();
    // await testToken.deployed();

    // console.log("testToken address : ", testToken.address);

    // const eAAts = await ethers.getContractFactory("eAAts");
    // const consumerAddress = consumer.address;

    // const deliveryFee = ethers.utils.parseEther("3");
    // eaats = await eAAts.deploy(consumerAddress, 466, source, testToken.address, deliveryFee);
    // await eaats.deployed();

    // console.log("eaats address : ", eaats.address);

    // const donId = "fun-polygon-mumbai-1";
    // // console.log(ethers.utils.formatBytes32String(donId));
    // await eaats.performUpkeep("0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});