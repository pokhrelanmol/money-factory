// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Staking {
    address public owner;
    struct Position {
        uint positionId;
        address staker;
        uint createdDate;
        uint unlockDate;
        uint stakeAmount;
        uint intrestRate;
        uint intrestEarned;
        bool open;
    }
    uint public currentPositionId;
    mapping(uint => Position) public positions;
    mapping(address => uint[]) public positionIdsByAddress;
    mapping(uint => uint) public tiers;
    uint[] public lockingPeriods;

    constructor() payable {
        owner = msg.sender;
        tiers[30] = 700;
        tiers[90] = 1000;
        tiers[180] = 1200;

        lockingPeriods.push(30);
        lockingPeriods.push(90);
        lockingPeriods.push(180);
    }

    function stake(uint8 numOfDays) external payable {
        require(msg.value > 0, "invalid ether send");
        require(tiers[numOfDays] > 0, "tiers not found");
        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            block.timestamp + (numOfDays * 1 days),
            msg.value,
            tiers[numOfDays],
            calculateIntrest(tiers[numOfDays], numOfDays, msg.value),
            true
        );
        positionIdsByAddress[msg.sender].push(currentPositionId);
        currentPositionId++;
    }

    function calculateIntrest(
        uint basisPoints,
        uint noOfDays,
        uint amount
    ) internal pure returns (uint) {
        return (basisPoints * amount) / 100;
    }

    function modifyLockPeriod(uint numDays, uint basisPoints) external {
        require(msg.sender == owner, "Only Owner");
        tiers[numDays] = basisPoints;
        lockingPeriods.push(numDays);
    }

    function getLockPeriod() external view returns (uint[] memory) {
        return lockingPeriods;
    }

    function getIntrestRate(uint numDays) external view returns (uint) {
        return tiers[numDays] / 100;
    }

    function getPositionById(uint id) external view returns (Position memory) {
        return positions[id];
    }

    function getStakerPositionIds(
        address staker
    ) external view returns (uint[] memory) {
        return positionIdsByAddress[staker];
    }

    function closePosition(uint positionId) external {
        Position memory _position = positions[positionId];
        require(msg.sender == _position.staker, "Only staker");
        require(_position.open, "postion already closed");
        positions[positionId].open = false;
        if (block.timestamp > _position.unlockDate) {
            uint amount = _position.stakeAmount + _position.intrestEarned;
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "ether transfer failed");
        } else {
            (bool success, ) = msg.sender.call{value: _position.stakeAmount}(
                ""
            );
            require(success, "ether transfer failed");
        }
    }
}
