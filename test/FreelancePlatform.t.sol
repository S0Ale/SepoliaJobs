// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import { Test } from "forge-std/Test.sol";
import "../contracts/FreelancePlatform.sol";

contract PlatformTest is Test {

    address owner;
    address client;
    address freelancer;

    FreelancePlatform c;

    uint constant testJobID = 1;

    function setUp() virtual public {
        c = new FreelancePlatform();

        owner = address(0x1);
        client = address(0x2);
        freelancer = address(0x3);

        vm.deal(owner, 10 ether);
        vm.deal(client, 10 ether);
        vm.deal(freelancer, 10 ether);
    }

}

contract JobCreationTests is PlatformTest {

    function testCreateJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", 4000000000);

        (, , , , , , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Open), "The job should be created successfully");
    }

    function testValueIsZero() public {
        vm.prank(client);
        try c.createJob("Test", 4000000000) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The payment should be greater than 0", "An unknown error occurred");
        }
    }


    function testDeadlineIsPast() public {
        vm.prank(client);
        try c.createJob{value: 100}("Test", 1) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The deadline cannot be a past date", "An unknown error occurred");
        }
    }

}

contract ApplicationTests is PlatformTest {

    function setUp() public override {
        super.setUp();

        vm.prank(client);
        c.createJob{value: 100}("Test", 4000000000);
    }

    function testApplyToJob() public {
        vm.prank(freelancer);
        c.applyToJob(testJobID);
        assertTrue(true, "The test has executed successfully");
    }

    function testApplicantIsClient() public {
        vm.prank(client);
        try c.applyToJob(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "A client cannot apply to its own job", "An unknown error occurred");
        }
    }

    function testApproveFreelancer() public {
        
    }

}

/*contract ApplyApproveTests is FreelancePlatformTest {

    uint constant testJobID = 1;

    /// #value: 100
    /// #sender: account-1
    function beforeAll() public payable {
        jobs[testJobID] = Job({
            id: testJobID,
            client: payable(msg.sender),
            freelancer: payable(address(0)),
            desc: "Test",
            payment: msg.value,
            deadline: 4000000000,
            state: JobState.Open
        });
    }

    /// #sender: account-2
    function testApplyToJob() public {
        applyToJob(testJobID);
        Assert.ok(true, "The method should be executed successfully");
    }

    /// #sender: account-1
    function testApproveFreelancer() public {
        approveFreelancer(testJobID, freelancer);
        Assert.equal(uint(jobs[testJobID].state), uint(JobState.Assigned), "The job should be assigned");
    }

}

contract SubmitAndApproveTests is FreelancePlatformTest {

    uint constant testJobID = 1;

    /// #value: 100
    /// #sender: account-1
    function beforeAll() public payable {
        jobs[testJobID] = Job({
            id: testJobID,
            client: payable(msg.sender),
            freelancer: payable(address(0)),
            desc: "Test",
            payment: msg.value,
            deadline: 4000000000,
            state: JobState.Open
        });
        approveFreelancer(testJobID, freelancer);
    }

    /// #sender: account-2
    function testSubmitWork() public {
        submitWork(testJobID);
        Assert.equal(uint(jobs[testJobID].state), uint(JobState.Submitted), "The job's state should be submitted");
    }

}
*/
