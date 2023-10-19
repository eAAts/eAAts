const {
  expect
} = require("chai");

describe("eAAts", function () {
  let eaats, testToken, testAAFactory, testAA;
  let deployer, addr1, addr2, addr3;

  before(async () => {
    [deployer, addr1, addr2, addr3] = await ethers.getSigners();

    const TestToken = await ethers.getContractFactory("TestToken");
    testToken = await TestToken.deploy();
    await testToken.deployed();

    const TestAAFactory = await ethers.getContractFactory("TestAAFactory");
    testAAFactory = await TestAAFactory.deploy();
    await testAAFactory.deployed();

    const eAAts = await ethers.getContractFactory("eAAts");
    const deliveryFee = ethers.utils.parseEther("3");
    eaats = await eAAts.deploy(testAAFactory.address, testToken.address, deliveryFee);
    await eaats.deployed();
  });

  describe("Address 1", function () {
    it("should create a wallet for the address", async function () {
      await testAAFactory.connect(deployer).createAA(addr1.address);

      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr1.address);
      expect(createdWalletAddress).to.not.be.equal(ethers.constants.AddressZero);
    });

    it("should max approve token", async function () {
      const maxUint256 = ethers.constants.MaxUint256.toString();

      const approveData = testToken.interface.encodeFunctionData("approve", [
        eaats.address,
        maxUint256,
      ]);

      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr1.address);
      testAA = await ethers.getContractAt("TestAA", createdWalletAddress);

      await testAA.run(testToken.address, 0, approveData);

      const allowance = await testToken.allowance(testAA.address, eaats.address);
      expect(allowance.toString()).to.equal(maxUint256);
    });

    it("should update balance after minting tokens", async function () {
      const sendAmount = ethers.utils.parseEther("1000");
      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr1.address);

      await testToken.connect(deployer).mint(createdWalletAddress, sendAmount);

      const balance = await testToken.balanceOf(createdWalletAddress);
      expect(balance.toString()).to.equal(sendAmount.toString());
    });
  });
  describe("Address 2", function () {
    it("should create a wallet for the address", async function () {
      await testAAFactory.connect(deployer).createAA(addr2.address);

      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr2.address);
      expect(createdWalletAddress).to.not.be.equal(ethers.constants.AddressZero);
    });

    it("should max approve token", async function () {
      const maxUint256 = ethers.constants.MaxUint256.toString();

      const approveData = testToken.interface.encodeFunctionData("approve", [
        eaats.address,
        maxUint256,
      ]);

      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr2.address);
      testAA = await ethers.getContractAt("TestAA", createdWalletAddress);

      await testAA.run(testToken.address, 0, approveData);

      const allowance = await testToken.allowance(testAA.address, eaats.address);
      expect(allowance.toString()).to.equal(maxUint256);
    });

    it("should update balance after minting tokens", async function () {
      const sendAmount = ethers.utils.parseEther("1000");
      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr2.address);

      await testToken.connect(deployer).mint(createdWalletAddress, sendAmount);

      const balance = await testToken.balanceOf(createdWalletAddress);
      expect(balance.toString()).to.equal(sendAmount.toString());
    });
  });

  describe("Address 3", function () {
    it("should create a wallet for the address", async function () {
      await testAAFactory.connect(deployer).createAA(addr3.address);

      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr3.address);
      expect(createdWalletAddress).to.not.be.equal(ethers.constants.AddressZero);
    });

    it("should max approve token", async function () {
      const maxUint256 = ethers.constants.MaxUint256.toString();

      const approveData = testToken.interface.encodeFunctionData("approve", [
        eaats.address,
        maxUint256,
      ]);

      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr3.address);
      testAA = await ethers.getContractAt("TestAA", createdWalletAddress);

      await testAA.run(testToken.address, 0, approveData);

      const allowance = await testToken.allowance(testAA.address, eaats.address);
      expect(allowance.toString()).to.equal(maxUint256);
    });

    it("should update balance after minting tokens", async function () {
      const sendAmount = ethers.utils.parseEther("1000");
      const createdWalletAddress = await testAAFactory.getAccountAbstraction(addr3.address);

      await testToken.connect(deployer).mint(createdWalletAddress, sendAmount);

      const balance = await testToken.balanceOf(createdWalletAddress);
      expect(balance.toString()).to.equal(sendAmount.toString());
    });
  });

  describe("createOrder, joinOrder, and completeDelivery", function () {
    it("should create an order with Equal fee and complete delivery", async function () {
      const minParticipants = 3;
      const feeType = 0;

      await eaats.createOrder(minParticipants, feeType);

      const orderId = 1;

      // Join the order
      const amount1 = ethers.utils.parseEther("10");
      const amount2 = ethers.utils.parseEther("20");
      const amount3 = ethers.utils.parseEther("30");

      await eaats.connect(addr1).joinOrder(orderId, amount1);
      await eaats.connect(addr2).joinOrder(orderId, amount2);
      await eaats.connect(addr3).joinOrder(orderId, amount3);

      // Complete the delivery
      await eaats.connect(deployer).completeDelivery(orderId);

      // Check the order status
      const order = await eaats.orders(orderId);
      expect(order.status).to.equal(2);
    });

    it("should create an order with Proportional fee and complete delivery", async function () {
      const minParticipants = 3;
      const feeType = 1;

      await eaats.createOrder(minParticipants, feeType);

      const orderId = 2;

      // Join the order
      const amount1 = ethers.utils.parseEther("10");
      const amount2 = ethers.utils.parseEther("20");
      const amount3 = ethers.utils.parseEther("30");

      await eaats.connect(addr1).joinOrder(orderId, amount1);
      await eaats.connect(addr2).joinOrder(orderId, amount2);
      await eaats.connect(addr3).joinOrder(orderId, amount3);

      // Complete the delivery
      await eaats.connect(deployer).completeDelivery(orderId);

      // Check the order status
      const order = await eaats.orders(orderId);
      expect(order.status).to.equal(2);
    });
  });
});