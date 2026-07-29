// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import { Test } from "forge-std/Test.sol";
import "../contracts/FreelancePlatform.sol";

contract PlatformTest is Test {

    address owner;
    address client;
    address freelancer;
    address other;

    FreelancePlatform c;

    uint constant testJobID = 1;

    function setUp() virtual public {
        owner = address(0x1);
        client = address(0x2);
        freelancer = address(0x3);
        other = address(0x4);

        vm.deal(owner, 10 ether);
        vm.deal(client, 10 ether);
        vm.deal(freelancer, 10 ether);

        vm.prank(owner);
        c = new FreelancePlatform();
    }

}
