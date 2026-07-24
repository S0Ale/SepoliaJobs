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

    function createJob() {}

    function applyForJob() {}

    function approveFreelancer() {}

    function submitWork() {}

    function approvePayment() {}

    function openDispute() {}

    function resolveDispute() {}

    function refund() {}

}