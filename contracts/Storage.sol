// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.16;

import "./ISBT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Storage is Ownable {
    enum TransferType {
        UPVOTE,
        DOWNVOTE
    }

    struct Relationship {
        int256 karmaAmount; // if bigger than 0 - user mostly upvoted him
        int16 relationshipRating; // more upvotes - more bounds
    }

    struct User {
        bool isInitialized;
        uint256 userId;
        int256 karma; // should be between +10 and -10
        mapping(address => Relationship) outgoing;
        mapping(address => Relationship) ingoing;
    }

    // storages
    mapping(address => bool) public hasSBT;
    mapping(address => User) public users;
    // allows to add multiple SBT tokens from different KYC providers
    mapping(ISBT => bool) public supportedContracts;

    modifier isSoulbounded() {
        require(hasSBT[msg.sender], "Storage: User is not soulbounded");
        _;
    }

    function addSBT(ISBT sbt) external onlyOwner {
        supportedContracts[sbt] = true;
    }

    function createUser(ISBT sbt) external {
        require(supportedContracts[sbt], "Storage: Contract not supported");
        require(
            sbt.tokenOf(msg.sender) != 0,
            "Storage: User does not have a KYC"
        );
        hasSBT[msg.sender] = true;
        User storage user = users[msg.sender];
        require(!user.isInitialized, "Storage: User has been initialized");
        user.isInitialized = true;
        user.karma = 100; // + 100
    }

    function sendKarma(
        address to,
        int16 amount,
        TransferType transfer
    ) external isSoulbounded {
        User storage user = users[msg.sender];
        require(
            amount < 1000 && amount > -1000,
            "Storage: Invalid karma value"
        );
        require(user.karma >= amount, "Storage: Insufficient karma");

        if (transfer == TransferType.UPVOTE) {
            _upvote(user, to, amount);
        } else {
            _downvote(user, to, amount);
        }
    }

    function getUserKarma(address user) external view returns (int256) {
        require(user != address(0), "Storage: Invalid address");
        return users[user].karma; 
    }

    function _upvote(
        User storage user,
        address to,
        int16 amount
    ) internal {
        User storage receiver = users[to];
        (int256 transferKarma, int16 transferRating) = _calculateTransfer(
            user.karma,
            receiver.karma,
            user.outgoing[to].relationshipRating,
            amount
        );
        user.karma -= amount;
        unchecked {
            receiver.karma += transferKarma;        
        }
        int16 relationshipRating = user.outgoing[to].relationshipRating + transferRating;
        user.outgoing[to].relationshipRating = relationshipRating; 
        receiver.ingoing[msg.sender].relationshipRating = relationshipRating;
    }

    function _downvote(
        User storage user,
        address to,
        int16 amount
    ) internal {
        User storage receiver = users[to];
          (int256 transferKarma, int16 transferRating) = _calculateTransfer(
            user.karma,
            receiver.karma,
            user.outgoing[to].relationshipRating,
            amount
        );

        receiver.karma -= transferKarma;        
        int16 relationshipRating = user.outgoing[to].relationshipRating + transferRating;
        user.outgoing[to].relationshipRating = relationshipRating; 
        receiver.ingoing[msg.sender].relationshipRating = relationshipRating;
    }

    function _calculateTransfer(
        int256 senderKarma,
        int256 receiverKarma,
        int256 bonding,
        int16 amount
    ) internal pure returns (int256 karma, int16 rating) {
        (int256 biggestKarma, int256 smallestKarma) = (senderKarma >
            receiverKarma)
            ? (senderKarma, receiverKarma)
            : (receiverKarma, senderKarma);
        int256 difference = biggestKarma - smallestKarma;
        int256 weightedKarma = (bonding * amount) / difference;

        if (weightedKarma > 5) {
            weightedKarma = 5;
        } else if (weightedKarma < 5) {
            weightedKarma = -5; 
        }
        
        if (senderKarma == biggestKarma) {
            karma = amount - weightedKarma;
        } else {
            karma = amount + weightedKarma;
        }

        rating = amount / 10;
    }
}
