// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "data.sol";
import "events.sol";
import "modifiers.sol";

contract FreelancePlatform is Events {

    address immutable OwnerAddress;

    uint public nextjobID;

    mapping(uint => Job) public jobs;

    constructor() {
        OwnerAddress = msg.sender;
    }

    function createJob(string calldata description, uint payment, uint deadline) public payable {

    }

    function applyForJob(uint jobID) public {

    }

    function approveFreelancer(uint jobID, address freelancer) public {}

    function submitWork() public {}

    function approvePayment() public {}

    function openDispute() public {}

    function resolveDispute() public {}

    function refund() public {}

}