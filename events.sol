// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

abstract contract Events {

    event FreelancerApplied(
        uint256 indexed jobId,
        address indexed freelancer,
        uint256 timestamp
    );

}