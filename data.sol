// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

enum JobState {
    Open,
    Expired,
    Assigned,
    Submitted,
    Disputed,
    Completed,
    Settled
}

struct Job {
    uint id;

    address payable client;
    address payable freelancer;

    string desc;
    uint payment;
    uint deadline;

    JobState state;
}