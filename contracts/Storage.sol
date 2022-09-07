// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Storage is Ownable {
    // conect library
    using Counters for Counters.Counter;
    Counters.Counter public contractIdTracker;
    // storages
    mapping(address => bool) public sBTInUser; //contract address => user address => true/false
    mapping(address => User) public users;

    modifier hasSBT() {
        require(sBTInUser[msg.sender] == true, "you don`t have SBT token");
        _;
    }

    struct SendedPoint {
        address to;
        uint256 amount;
    }

    struct User {
        address userAddress;
        uint256 userId;
        uint256 weight;
        uint256 karma;
        SendedPoint[] sendedKarma;
        SendedPoint[] sendedPoint;
    }
    SendedPoint[] private sendedPoint;

    // Karma send logic
    function sendKarma(address useraddress, uint256 karmaAmount) public hasSBT {
        require(
            karmaAmount <= users[msg.sender].weight,
            "You don`t have enought karma"
        );
        require(
            users[msg.sender].weight > 0,
            "You weight is to low to send karma"
        );
        users[msg.sender].sendedKarma.push(
            SendedPoint(useraddress, karmaAmount)
        );
        users[useraddress].karma += karmaAmount;
        // TO DO!!! change formula
        users[msg.sender].weight = users[msg.sender].weight - karmaAmount;
    }

    // weight send logic
    function sendPoint(address useraddress, uint256 weight) public hasSBT {
        require(weight <= users[msg.sender].weight, "You weight is to low");
        users[msg.sender].sendedPoint.push(SendedPoint(useraddress, weight));
        users[useraddress].weight += weight;
    }

    // get user Info
    function getUserInfo(address user)
        public
        view
        returns (User memory userInfo)
    {
        return users[user];
    }

    function createUser() public hasSBT {
        sendedPoint.push(SendedPoint(msg.sender, 0));
        users[msg.sender] = User(
            msg.sender,
            contractIdTracker.current(),
            100,
            100,
            sendedPoint,
            sendedPoint
        );
    }
}
