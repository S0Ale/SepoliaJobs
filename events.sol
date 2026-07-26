// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

abstract contract Events {

    event FreelancerApplied(
        uint indexed jobID,
        address indexed freelancer,
        uint timestamp
    );

    event DisputeOpened(
        uint indexed jobID,
        address indexed opener,
        uint timestamp
    );

    event DisputeComment(
        uint indexed jobID,
        address indexed author,
        string text,
        uint timestamp
    );

    event DisputeClosed(
        uint indexed jobID,
        bool isClient,
        uint timestamp
    );

}