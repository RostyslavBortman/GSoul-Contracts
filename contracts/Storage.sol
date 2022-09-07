// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Storage is Ownable {
    enum TransferType {
        UPVOTE,
        DOWNVOTE
    }

    struct Relationship {
        int256 karmaAmount; // if bigger than 0 - user mostly upvoted him
        int256 relationshipRating; // more upvotes - more bounds
    }

    struct User {
        bool isInitialized;
        uint256 userId;
        int256 karma; // should be between +10 and -10
        mapping(address => Relationship) outgoing;
        mapping(address => Relationship) ingoing;
    }

    // conect library
    using Counters for Counters.Counter;
    Counters.Counter public contractIdTracker;
    // storages
    mapping(address => bool) public hasSBT;
    mapping(address => User) public users;

    modifier isSoulbounded() {
        require(hasSBT[msg.sender], "Storage: User is not soulbounded");
        _;
    }

    function createUser() external isSoulbounded {
        User storage user = users[msg.sender];
        require(!user.isInitialized, "Storage: User has been initialized");
        user.isInitialized = true;
        user.karma = 100; // + 100
    }

    // Karma send logic
    function sendKarma(
        address to,
        uint256 u_amount,
        TransferType transfer
    ) external isSoulbounded {
        User storage user = users[msg.sender];
        require(u_amount > 0, "");
        //todo: check before converting
        int256 amount = int256(u_amount); 
        require(user.karma >= amount, "Storage: Insufficient karma");

        if (transfer == TransferType.UPVOTE) {
            _upvote(user, to, amount);
        } else {
            _downvote(user, to, amount);
        }
    }

    function _upvote(
        User storage user,
        address to,
        int256 amount
    ) internal {
        User storage receiver = users[to];

        user.karma -= amount;

        (int256 karma, int256 rating) = _calculateTransfer(user.karma, receiver.karma);

        // unchecked {
        //     user.outgoing[to] =
        //     receiver.ingoing[msg.sender] =
        //     user.karmaUpvotes[to] = user.karmaUpvotes[to] + amount;
        //     receiver.karma += amount;
        // }
    }

    function _downvote(
        User storage user,
        address to,
        int256 amount
    ) internal {
        User storage receiver = users[to];

        user.karma -= amount;

      
    }

    function _calculateTransfer(int256 senderKarma, int256 receiverKarma)
        internal
        returns (int256 karma, int256 rating)
    {
        (int256 biggestKarma, int256 smallestKarma) = (senderKarma >
            receiverKarma)
            ? (senderKarma, receiverKarma)
            : (receiverKarma, senderKarma);
        int256 difference = biggestKarma - smallestKarma;
        //todo: deliver math
    }
}