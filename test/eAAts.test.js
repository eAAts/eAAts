const {
  expect
} = require("chai");

describe("eAAts", function () {
  let eaats, testToken;
  let deployer, addr1, addr2, consumer;

  before(async () => {
    [deployer, addr1, addr2, consumer] = await ethers.getSigners();

    const TestToken = await ethers.getContractFactory("TestToken");
    testToken = await TestToken.deploy();
    await testToken.deployed();

    const eAAts = await ethers.getContractFactory("eAAts");
    const deliveryFee = ethers.utils.parseEther("3");
    eaats = await eAAts.deploy(consumer.address, "1", "1", testToken.address, deliveryFee);
    await eaats.deployed();
  });

  describe("createOrder", function () {
    it("Should create an order and emit an OrderCreated event", async function () {
      const minParticipants = 2;
      const feeType = 0; // FeeType.Equal

      await expect(eaats.createOrder(minParticipants, feeType))
        .to.emit(eaats, "OrderCreated")
        .withArgs(1, deployer.address, minParticipants, feeType);
    });
  });

  describe("joinOrder", function () {
    it("Should allow a user to join an order and emit an OrderJoined event", async function () {
      const amount = ethers.utils.parseEther("1");

      await testToken.approve(eaats.address, amount);
      await expect(eaats.connect(addr1).joinOrder(1, amount, 1))
        .to.emit(eaats, "OrderJoined")
        .withArgs(1, addr1.address, amount);
    });
  });

  describe("completeDelivery", function () {
    it("Should mark an order as completed and emit a DeliveryCompleted event", async function () {
      const minParticipants = 2;
      const feeType = 0; // FeeType.Equal
      const amount = ethers.utils.parseEther("1");
      const deliveryFee = ethers.utils.parseEther("3");

      await eaats.createOrder(minParticipants, feeType);

      await testToken.mint(addr1.address, deliveryFee.div(minParticipants));
      await testToken.connect(addr1).approve(eaats.address, deliveryFee.div(minParticipants));
      
      await testToken.mint(addr2.address, deliveryFee.div(minParticipants));
      await testToken.connect(addr2).approve(eaats.address, deliveryFee.div(minParticipants));
      await eaats.connect(addr2).joinOrder(1, amount, 1);

      await expect(eaats.completeDelivery(1))
        .to.emit(eaats, "DeliveryCompleted")
        .withArgs(1);
    });
  });
});