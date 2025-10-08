// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is VRFConsumerBaseV2, Ownable, AutomationCompatibleInterface {
    VRFCoordinatorV2Interface COORDINATOR;

    // Sepolia 測試網 Chainlink VRF 參數
    uint64 subscriptionId;
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    // 彩票狀態
    address[] public players;
    mapping(address => bool) public isMember;
    uint256 public entryFee = 0.01 ether;
    bool public lotteryOpen = false;
    address public winner;
    uint256 public requestId;
    bool public pendingVRF = false;
    uint256 public constant MIN_PLAYERS = 2;
    uint256 public endTime; // 彩票結束時間
    uint256 public constant LOTTERY_DURATION = 1 days; // 彩票持續時間（可調整）

    // 事件
    event Entered(address indexed player, uint256 amount);
    event LotteryStarted(uint256 endTime);
    event LotteryEnded(address indexed winner);
    event PrizeWithdrawn(address indexed winner, uint256 amount);
    event EntryFeeUpdated(uint256 newFee);

    constructor(uint64 _subscriptionId) VRFConsumerBaseV2(vrfCoordinator) Ownable(msg.sender) {
        require(_subscriptionId != 0, "Invalid subscription ID");
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subscriptionId = _subscriptionId;
    }

    function enter() external payable {
        require(lotteryOpen, "Lottery is not open");
        require(msg.value == entryFee, "Incorrect entry fee");
        require(!isMember[msg.sender], "Already joined");
        isMember[msg.sender] = true;
        players.push(msg.sender);
        emit Entered(msg.sender, entryFee);
    }

    function startLottery() external onlyOwner {
        require(!lotteryOpen, "Lottery already open");
        require(address(this).balance == 0, "Prize not withdrawn");
        for (uint256 i = 0; i < players.length; i++) {
            isMember[players[i]] = false;
        }
        delete players;
        winner = address(0);
        lotteryOpen = true;
        endTime = block.timestamp + LOTTERY_DURATION;
        emit LotteryStarted(endTime);
    }

    function endLottery() public {
        require(lotteryOpen, "Lottery not open");
        require(players.length >= MIN_PLAYERS, "Not enough players");
        require(address(this).balance == players.length * entryFee, "Balance mismatch");
        lotteryOpen = false;
        pendingVRF = true;
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        require(!lotteryOpen, "Lottery still open");
        require(pendingVRF, "No pending VRF request");
        require(randomWords.length > 0, "Invalid random words");
        pendingVRF = false;
        uint256 index = randomWords[0] % players.length;
        winner = players[index];
        emit LotteryEnded(winner);
    }

    function withdrawPrize() external {
        require(msg.sender == winner, "Not the winner");
        require(address(this).balance > 0, "No prize to withdraw");
        uint256 prize = address(this).balance;
        winner = address(0);
        (bool success, ) = payable(msg.sender).call{value: prize}("");
        require(success, "Prize transfer failed");
        emit PrizeWithdrawn(msg.sender, prize);
    }

    function setEntryFee(uint256 _newFee) external onlyOwner {
        require(_newFee > 0, "Entry fee must be positive");
        entryFee = _newFee;
        emit EntryFeeUpdated(_newFee);
    }

    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Chainlink Automation 函數
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = lotteryOpen && block.timestamp >= endTime && players.length >= MIN_PLAYERS;
        performData = "";
        return (upkeepNeeded, performData);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        require(lotteryOpen, "Lottery not open");
        require(block.timestamp >= endTime, "Lottery not yet ended");
        require(players.length >= MIN_PLAYERS, "Not enough players");
        endLottery();
    }
}