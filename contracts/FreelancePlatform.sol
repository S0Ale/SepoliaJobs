// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./data.sol";
import "./events.sol";
import "./errors.sol";

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
    modifier modOnly() {
        require(msg.sender == OwnerAddress, "The user is not a moderator");
        _;
    }

    modifier clientOnly(uint _jobID) {
        require(msg.sender == jobs[_jobID].client, "The user is not the job's client");
        _;
    }

    // NOTE (DanieleErcole): A job is valid for sure if job.state != Open, because that is the default value for the enum
    modifier validJob(uint _jobID) {
        require(_jobID > invalidJobID && _jobID < nextjobID, "The specified job does not exists");
        _;
    }

    modifier notExpired(uint _jobID) {
        require(block.timestamp < jobs[_jobID].deadline, "The specified job's deadline is expired");
        _;
    }

    constructor() {
        OwnerAddress = msg.sender;
    }

    function createJob(string calldata title, string calldata description, uint deadline) public payable {
        require(msg.value > 0, "The payment should be greater than 0");
        require(block.timestamp < deadline, "The deadline cannot be a past date");

        Job memory newJob = Job({
            client: payable(msg.sender),
            freelancer: payable(address(0)),
            title: title,
            desc: description,
            payment: msg.value,
            deadline: deadline,
            state: JobState.Open
        });
        jobs[nextjobID] = newJob;

        emit JobCreated(nextjobID, newJob, block.timestamp);
        nextjobID++;
    }

    function deleteJob(uint jobID) public notExpired(jobID) clientOnly(jobID) noReentrancy {
        Job storage job = jobs[jobID];

        assert(address(this).balance >= job.payment);
        require(job.state == JobState.Open, "An assigned job cannot be deleted");

        (bool success, ) = job.client.call{value: job.payment}("");
        require(success, "The refund to the client has failed");

        job.state = JobState.Deleted;
    }

    function applyToJob(uint jobID) public validJob(jobID) notExpired(jobID) {
        Job storage job = jobs[jobID];

        require(msg.sender != job.client, "A client cannot apply to its own job");
        require(job.state == JobState.Open, "The specified job cannot be applied to");

        emit FreelancerApplied(jobID, msg.sender, block.timestamp);
    }

    //TODO: check that this validJob check is useful, maybe I can remove it and use it only for applyToJob
    function approveFreelancer(uint jobID, address freelancer) public validJob(jobID) notExpired(jobID) clientOnly(jobID) {
        Job storage job = jobs[jobID];
        require(job.state != JobState.Deleted, "Interaction with a deleted job");
        require(job.freelancer == payable(address(0)), "Cannot approve more than one freelancer for a job");

        job.freelancer = payable(freelancer);
        job.state = JobState.Assigned;
    }

    function submitWork(uint jobID) public notExpired(jobID) {
        Job storage job = jobs[jobID];

        require(job.state == JobState.Assigned, "The job hasn't been assigned yet");
        require(msg.sender == job.freelancer, "You are not assigned to this job");
        job.state = JobState.Submitted;
    }

    function approvePayment(uint jobID) public noReentrancy clientOnly(jobID) {
        Job storage job = jobs[jobID];

        assert(address(this).balance >= job.payment);
        require(job.state == JobState.Submitted, "Nothing has been submitted yet");

        (bool success, ) = job.freelancer.call{value: job.payment}("");
        require(success, "The payment to the freelancer has failed");

        job.state = JobState.Completed;
    }

    function openDispute(uint jobID) public {
        Job storage job = jobs[jobID];

        require(job.state == JobState.Submitted, "Nothing has been submitted yet");
        require(msg.sender == job.client || msg.sender == job.freelancer, "The user must be the job's client or freelancer");

        job.state = JobState.Disputed;
        emit DisputeOpened(jobID, msg.sender, block.timestamp);
    }

    //TODO: maybe the involved users can put comments in the dispute?
    function commentDispute(uint jobID, string calldata text) public {
        Job storage job = jobs[jobID];

        require(job.state == JobState.Disputed, "The job is not being disputed");
        require(msg.sender == job.client || msg.sender == job.freelancer || msg.sender == OwnerAddress, "The user must be the job's client, freelancer or a moderator");

        emit DisputeComment(jobID, msg.sender, text, block.timestamp);
    }

    //TODO: add a function to send the proofs? stored where? maybe use IPFS but only off-chain

    function settle(uint jobID, bool isClient) public noReentrancy modOnly {
        Job storage job = jobs[jobID];

        assert(address(this).balance >= job.payment);
        require(job.state == JobState.Disputed, "The job is not being disputed");

        address payable recipient = isClient ? job.client : job.freelancer;
        (bool success, ) = recipient.call{value: job.payment}("");
        require(success, "The transfer to the recipient has failed");

        job.state = JobState.Settled;
        emit DisputeClosed(jobID, isClient, block.timestamp);
    }

}
