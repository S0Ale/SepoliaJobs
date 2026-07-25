// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "data.sol";
import "events.sol";
import "errors.sol";

contract FreelancePlatform is Events {

    uint constant invalidJobID = 0;
    address immutable OwnerAddress;

    uint public nextjobID = invalidJobID + 1;
    mapping(uint => Job) public jobs;

    bool public locked;

    modifier noReentrancy() {
        require(!locked, "No reentrancy");

        locked = true;
        _;
        locked = false;
    }

    //TODO: for now only the owner can settle disputes
    modifier onlyMod() {
        require(msg.sender == OwnerAddress);
        _;
    }

    modifier validJob(uint _jobID) {
        require(_jobID > invalidJobID && _jobID < nextjobID, "The specified job does not exists");
        _;
    }

    //TODO: for now I use this to check job's expiration
    modifier notExpired(uint _jobID) {
        JobState state = jobs[_jobID].state;
        require(jobs[_jobID].state != JobState.Expired, "The specified job's deadline is expired");
        if((state == JobState.Open || state == JobState.Assigned) && block.timestamp <= jobs[_jobID].deadline) {
            jobs[_jobID].state = JobState.Expired;
            revert DeadlineExpired(_jobID);
        }
        _;
    }

    constructor() {
        OwnerAddress = msg.sender;
    }

    function createJob(string calldata description, uint deadline) public payable {
        require(msg.value >= 0 ether, "The payment should be greater than 0");
        require(block.timestamp >= deadline, "The deadline cannot be a past date");
        
        jobs[nextjobID] = Job({
            id: nextjobID++,
            client: payable(msg.sender),
            freelancer: payable(address(0)),
            desc: description,
            payment: msg.value,
            deadline: deadline,
            state: JobState.Open
        });

        //TODO: event for job creation?
    }

    function applyToJob(uint jobID) public validJob(jobID) notExpired(jobID) {
        require(jobs[jobID].state == JobState.Open, "The specified job cannot be applied to");
        emit FreelancerApplied(jobID, msg.sender, block.timestamp);
    }

    //TODO: check that this validJob check is useful, maybe I can remove it and use it only for applyToJob
    function approveFreelancer(uint jobID, address freelancer) public validJob(jobID) notExpired(jobID) {
        require(msg.sender == jobs[jobID].client, "The user is not the job's client");
        require(jobs[jobID].freelancer == payable(address(0)), "Cannot approve more than one freelancer for a job");

        jobs[jobID].freelancer = payable(freelancer);
        jobs[jobID].state = JobState.Assigned;
    }

    function submitWork(uint jobID) public notExpired(jobID) {
        require(jobs[jobID].state == JobState.Assigned, "The job hasn't been assigned yet");
        require(jobs[jobID].freelancer == msg.sender, "You are not assigned to this job");
        jobs[jobID].state = JobState.Submitted;
    }

    function approvePayment(uint jobID) public noReentrancy {
        require(address(this).balance >= jobs[jobID].payment);
        require(jobs[jobID].state == JobState.Submitted, "Nothing has been submitted yet");

        (bool success, ) = jobs[jobID].freelancer.call{value: jobs[jobID].payment}("");
        require(success, "The payment to the freelancer has failed");

        jobs[jobID].state = JobState.Completed;
    }

    function openDispute(uint jobID) public {
        require(jobs[jobID].state == JobState.Submitted, "Nothing has been submitted yet");
        require(msg.sender == jobs[jobID].client || msg.sender == jobs[jobID].freelancer, "The user must be the job's client or freelancer");

        jobs[jobID].state = JobState.Disputed;
    }

    function settle(uint jobID, bool isClient) public noReentrancy onlyMod {
        require(address(this).balance >= jobs[jobID].payment);
        require(jobs[jobID].state == JobState.Disputed, "The job is not being disputed");

        address recipient = isClient ? jobs[jobID].client : jobs[jobID].freelancer;
        (bool success, ) = recipient.call{value: jobs[jobID].payment}("");
        require(success, "The refund to the recipient has failed");

        jobs[jobID].state = JobState.Settled;
    }

}