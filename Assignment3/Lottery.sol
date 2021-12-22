// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./VRFConsumerBase.sol";
import "hardhat/console.sol";

contract Lottery is Ownable, VRFConsumerBase, ReentrancyGuard {
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING_WINNER, CLAIM_REWARDS, WINNER_CLAIMED }
    LOTTERY_STATE public lottery_state;
    address payable public manager;
    address payable[] public players;
    uint public lotteryId = 0;
    uint public constant TICKET_PRICE = 0.1 ether;
    uint constant TICKETS_LIMIT = 100;
    uint totalExpectedBalance = TICKETS_LIMIT * TICKET_PRICE;
    bool public winnerPicked = false;
    address payable public winner;

    // VRF
    bytes32 internal keyHash;
    uint256 internal fee;
    
    event BuyTicket(address indexed ticketOwner, uint ticketId);
    event Winner(bytes32 requestId, uint Number, address indexed winner);
    event Transfer(address indexed receiver, uint amount);

    // VRFConsumerBase(VRF Coordinator, LINK Token)
     constructor() 
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token (Rinkeby Address)
        ) 
    {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)

        lottery_state = LOTTERY_STATE.CLOSED;
        manager = payable(getOwner());
    }

    function startNewLottery() external onlyOwner {
        require(lottery_state == LOTTERY_STATE.CLOSED, "can't start a new lottery yet");
        lottery_state = LOTTERY_STATE.OPEN;

        winnerPicked = false;
        players = new address payable[](0); // Dynamic Array with Intial Size 0
        players.push(payable(address(0))); // Initialize first element with 0
        lotteryId++;
    }
    
    function buyTickets() external payable nonReentrant {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery: Lottery is closed!");
        require(msg.value == TICKET_PRICE, "Lottery: Insufficient amount to buy lottery ticket!");
        
        uint ticketNumber = players.length;   // length 1 --> arr[0] = 0 --> So first ticket number 1
        players.push(payable(msg.sender));    // Pushed at ticket number index because arr[0] already has 0 value
        emit BuyTicket(msg.sender, ticketNumber);
        if(ticketNumber == TICKETS_LIMIT) {
            lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        }
    }


    function pickWinner() external onlyOwner nonReentrant {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "You aren't at that stage yet!");
        getRandomNumber();
    }

    function claimWinnerReward() external nonReentrant {
        require(lottery_state == LOTTERY_STATE.CLAIM_REWARDS, "Lottery: You aren't at that stage yet!");
        //  Winner through which they can claim their reward
        require(msg.sender == winner, "Lottery: Only Winner can claim his reward");
        require(address(this).balance >= totalExpectedBalance);
        uint winnerReward = (90 * totalExpectedBalance) / 100; // 90% of total lottery balance
        winner.transfer(winnerReward);
        winner = payable(address(0));
        emit Transfer(msg.sender, winnerReward);
        lottery_state = LOTTERY_STATE.WINNER_CLAIMED;
    }

    function collectAdminFunds() external onlyOwner nonReentrant {
        // Owner to collect his/her funds
        require(lottery_state == LOTTERY_STATE.WINNER_CLAIMED, "Lottery: Winner has not claimed his reward yet!");
        uint managerReward = (10 * totalExpectedBalance) / 100; // 10% of total lottery balance
        manager.transfer(managerReward);
        emit Transfer(msg.sender, managerReward);
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    /*------------------------------------------------
                    Helper Functions
    ------------------------------------------------*/

    // Generate Random Number
     /** 
     * Requests randomness 
     */
    function getRandomNumber() private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "ChainLink: Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint index = randomness % players.length; // Will return number b/w 0 and length-1
        if(index == 0) {
            index++;
        }

        winnerPicked = true;
        winner = players[index];
        emit Winner(requestId, index, winner);
        lottery_state = LOTTERY_STATE.CLAIM_REWARDS;
    }

    // Implement a withdraw function to avoid locking your LINK in the contract
    function withdrawLink() external {
        LINK.transfer(msg.sender, LINK.balanceOf(address(this)));
    }  

    function getAvailableLINK() view external onlyOwner returns(uint) {
        return LINK.balanceOf(address(this));
    }

    function getPlayers() view public returns(address payable[] memory) {
        return players;
    }

    function totalPlayers() view public returns(uint) {
        return players.length - 1;
    }
}