//giấy phép

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

error Raffle__SendMoreToEnterRaffle();
error Raffle__RaffleNotOpen();
error Raffle__UpkeepNotNeeded();
error Raffle__TransferFailed();


contract Raffle is VRFConsumerBaseV2 {
    enum RaffleState {
        Open,
        Calculating
    }

    RaffleState public s_raffleState;
    uint256 public immutable i_entranceFee;
    uint256 public immutable i_interval;
    address payable[] public s_players;
    uint256 public s_lastTimeStamp;
    VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
    bytes32 public immutable i_gasLane; //keyhash
    uint64 public immutable i_subscriptionId;
    uint32 public immutable i_callbackGasLimit;
    address public s_recentWinner;

    uint16 public constant REQUEST_CONFIRMATIONS = 3;
    uint32 public constant NUM_WORDS = 1;

    event RaffleEnter (address indexed player);
    event RequestedRaffleWinner (uint256 indexed requestId);
    event WinnerPicked (address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinatorV2,
        bytes32 gasLane, //keyhash
        uint64 subscriptionId,
        uint32 callbackGasLimit

    ) VRFConsumerBaseV2(vrfCoordinatorV2){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane; //keyhash
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        }

    function enterRaffel()  external payable {
        // require(msg.value >= i_entranceFee, "Not enough money sent!");
        if (msg.value < i_entranceFee) {
                revert Raffle__SendMoreToEnterRaffle();
        }
        // Open, caculating a winner
        if(s_raffleState != RaffleState.Open) {
            revert Raffle__RaffleNotOpen();
        }
        // bạn có thể vào!
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }


    //1.we want this done automatically
    //2. we want a read random winner

    //1. Be true after soem time interval
    //2. The lottery to be open
    //3. The contract has ETH
    // Keeper has L
    function checkUpkeep(
        bytes memory /*checkData*/
    ) public view returns (bool upkeepNeeded, bytes memory /*performData*/) {
        bool isOpen = RaffleState.Open == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(
        bytes calldata /*performData*/) 
        external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded();
        }
        // thực hiện việc rút thăm
        s_raffleState = RaffleState.Calculating;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //keyhash
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        // chọn người chiến thắng
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.Open;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }
}