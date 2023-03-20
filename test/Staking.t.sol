// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Staking.sol";

contract StakingTest is Test {
    Staking public staking;

    function setUp() public {
        staking = new Staking();
    }

    function test_Stake() public payable {
        staking.stake{value: 1000000000000000000}(30);
        console.log(staking.tiers(30));
    }

    function testFail_stake() public payable {
        staking.stake{value: 0}(30);
        // assertEq(staking.getIntrestRate(30),7);
    }

    // function testStaking(uint8 numOfDays) public payable{

    // }

    // function testSetNumber(uint256 x) public {
    //     // counter.setNumber(x);
    //     // assertEq(counter.number(), x);
    // }
}
