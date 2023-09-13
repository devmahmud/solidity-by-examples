// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Lottery {
    address[] public players; // Dynamic array with players' addresses

    address public manager; // Contract manager

    // Contract constructor, runs once at contract deployment
    constructor() {
        manager = payable(msg.sender); // The manager is the account address that deploys the contract
    }

    // This fallback payable function will be automatically called when somebody
    // sends ether to our contract address
    receive() external payable {
        require(msg.value >= 0.01 ether);
        players.push(msg.sender); // Add the address of the account that sends ether to players array
    }

    function getBalance() public view returns (uint256) {
        require(msg.sender == manager);
        return address(this).balance; // Return contract balance
    }

    // Returns a very big pseudo-random integer no.
    function random() public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    // Function to determine the winner randomly
    function selectWinner() public {
        require(msg.sender == manager); // Only manager can select the winner
        
        uint r = random();
        
        address payable winner;
        
        // A random index
        uint index = r % players.length;
        winner = payable(players[index]);
        
        // Transfer contract balance to the winner address
        winner.transfer(address(this).balance);
        
        delete players; // Resetting the players dynamic array
    }

    // Function to allow users to participate in the lottery
    function enterLottery() public payable {
        require(msg.value >= 0.01 ether);
        players.push(msg.sender);
    }
}
