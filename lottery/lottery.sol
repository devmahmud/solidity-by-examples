// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Lottery {
    address[] public players; // Dynamic array with players' addresses
    address public manager; // Contract manager
    uint public minimumPlayers; // Minimum number of players required
    uint public deadline; // Deadline for participation
    bool public lotteryOpen; // Flag to track if the lottery is open
    address payable public winner; // Address of the winner

    event NewPlayerEntered(address indexed player, uint indexed numberOfPlayers);
    event LotteryWinnerSelected(address indexed winner, uint indexed prize);

    // Contract constructor, runs once at contract deployment
    constructor(uint _minimumPlayers, uint _duration) {
        manager = payable(msg.sender); // The manager is the account address that deploys the contract
        minimumPlayers = _minimumPlayers;
        deadline = block.timestamp + _duration; // Duration in seconds
        lotteryOpen = true;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    modifier lotteryIsOpen() {
        require(lotteryOpen, "The lottery is closed");
        _;
    }

    modifier notManager() {
        require(msg.sender != manager, "The manager cannot participate");
        _;
    }

    // This fallback payable function will be automatically called when somebody
    // sends ether to our contract address
    receive() external payable lotteryIsOpen notManager {
        require(msg.value >= 0.01 ether, "Minimum participation is 0.01 ether");
        players.push(msg.sender);
        emit NewPlayerEntered(msg.sender, players.length);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance; // Return contract balance
    }

    // Returns a very big pseudo-random integer no.
    function random() public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    // Function to determine the winner randomly
    function selectWinner() public onlyManager lotteryIsOpen {
        require(block.timestamp >= deadline, "The deadline for participation has not been reached yet");
        require(players.length >= minimumPlayers, "Not enough players to select a winner");

        uint r = random();
        uint index = r % players.length;
        winner = payable(players[index]);
        emit LotteryWinnerSelected(winner, address(this).balance);

        winner.transfer(address(this).balance);
        lotteryOpen = false;
    }

    // Function to allow users to participate in the lottery
    function enterLottery() public payable notManager {
        require(msg.value >= 0.01 ether);
        players.push(msg.sender);
    }

    // Get number of players
    function numberOfPlayers() public view returns (uint) {
        return players.length;
    }
}
