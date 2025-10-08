import { ethers } from "hardhat";
import { expect } from "chai";
import { Lottery } from "../typechain-types";

describe("Lottery", function () {
  let lottery: Lottery;
  let owner: any, player1: any, player2: any;

  beforeEach(async function () {
    [owner, player1, player2] = await ethers.getSigners();
    const LotteryFactory = await ethers.getContractFactory("Lottery");
    lottery = await LotteryFactory.deploy(1234); // 替換為你的 Subscription ID
    await lottery.deployed();
  });

  it("should allow a player to enter with 0.01 ETH", async function () {
    await lottery.startLottery();
    await lottery.connect(player1).enter({ value: ethers.parseEther("0.01") });
    const players = await lottery.getPlayers();
    expect(players).to.include(player1.address);
    expect(await lottery.isMember(player1.address)).to.be.true;
  });

  it("should revert if entry fee is incorrect", async function () {
    await lottery.startLottery();
    await expect(
      lottery.connect(player1).enter({ value: ethers.parseEther("0.02") })
    ).to.be.revertedWith("Incorrect entry fee");
  });

  it("should revert if player already entered", async function () {
    await lottery.startLottery();
    await lottery.connect(player1).enter({ value: ethers.parseEther("0.01") });
    await expect(
      lottery.connect(player1).enter({ value: ethers.parseEther("0.01") })
    ).to.be.revertedWith("This member has already joined");
  });

  it("should allow owner to start lottery", async function () {
    await lottery.startLottery();
    expect(await lottery.lotteryOpen()).to.be.true;
    expect(await lottery.getPlayers()).to.be.empty;
  });

  it("should revert if non-owner tries to start lottery", async function () {
    await expect(lottery.connect(player1).startLottery()).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should reset isMember when lottery starts", async function () {
    await lottery.startLottery();
    await lottery.connect(player1).enter({ value: ethers.parseEther("0.01") });
    await lottery.connect(owner).endLottery(); // 假設 endLottery 設置 lotteryOpen = false
    await lottery.startLottery();
    expect(await lottery.isMember(player1.address)).to.be.false;
    await lottery.connect(player1).enter({ value: ethers.parseEther("0.01") });
  });

  it("should allow winner to withdraw prize", async function () {
    await lottery.startLottery();
    await lottery.connect(player1).enter({ value: ethers.parseEther("0.01") });
    await lottery.connect(player2).enter({ value: ethers.parseEther("0.01") });
    await lottery.connect(owner).endLottery();
    // 模擬 Chainlink VRF 回調（在本地測試中無法直接測試 VRF，需手動設置 winner）
    await lottery.connect(owner).fulfillRandomWords(1, [123]); // 模擬隨機數
    const winner = await lottery.winner();
    const balanceBefore = await ethers.provider.getBalance(winner);
    await lottery.connect(winner).withdrawPrize();
    const balanceAfter = await ethers.provider.getBalance(winner);
    expect(balanceAfter).to.be.gt(balanceBefore);
  });
});