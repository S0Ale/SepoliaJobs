// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./data.sol";

// User restrictions
error ModOnly();
error ClientOnly();

// Jobs
error InvalidJob(uint jobID);
error DeadlineExpired(uint jobID);
error ClientApplied();
error OnlyOneFreelancer();
error JobShouldBe(JobState req);

error UserNotAssignee();
error UserNotRelatedTo(uint jobID);

error PaymentZero();
error PastDate(uint date);