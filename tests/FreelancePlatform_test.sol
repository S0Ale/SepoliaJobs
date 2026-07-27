// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../FreelancePlatform.sol";

contract FreelancePlatformTest is FreelancePlatform {

    address owner = TestsAccounts.getAccount(0);
    address client = TestsAccounts.getAccount(1);
    address freelancer = TestsAccounts.getAccount(2);

}

contract JobCreationTests is FreelancePlatformTest {

    /// #value: 100
    /// #sender: account-1
    function testCreateJob() public payable {
        createJob("Test", 4000000000);
        Assert.equal(nextjobID - 1, 1, "The job should be created successfully");
    }

}

contract FreelancerTests is FreelancePlatformTest {

    /// #value: 100
    /// #sender: account-1
    function beforeAll() public payable {
        createJob("Test", 4000000000);
    }

    /// #sender: account-2
    function testApplyToJob() public {
        applyToJob(1);
        Assert.ok(true, "The method should be executed successfully");
    }

    /// #sender: account-1
    function testApproveFreelancer() public {
        approveFreelancer(1, freelancer);
        Assert.equal(uint(jobs[1].state), uint(JobState.Assigned), "The job should be assigned");
    }

}
    