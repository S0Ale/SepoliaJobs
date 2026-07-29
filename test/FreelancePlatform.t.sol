// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import { Test } from "forge-std/Test.sol";
import "../contracts/FreelancePlatform.sol";

contract PlatformTest is Test {

    address owner;
    address client;
    address freelancer;
    address other;

    FreelancePlatform c;

    uint constant testJobID = 1;

    function setUp() virtual public {
        owner = address(0x1);
        client = address(0x2);
        freelancer = address(0x3);
        other = address(0x4);

        vm.deal(owner, 10 ether);
        vm.deal(client, 10 ether);
        vm.deal(freelancer, 10 ether);

        vm.prank(owner);
        c = new FreelancePlatform();
    }

}

contract JobCreationTests is PlatformTest {

    function testCreateJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", 4000000000);

        (, , , , , , , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Open), "The job should be in the Open state");
    }

    function testValueIsZero() public {
        vm.prank(client);
        try c.createJob("Test", "A test", 4000000000) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The payment should be greater than 0", "An unknown error occurred");
        }
    }

    function testDeadlineIsPast() public {
        vm.prank(client);
        try c.createJob{value: 100}("Test", "A test", 1) {
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
        c.createJob{value: 100}("Test", "A test", 4000000000);
    }

    function testApplyToJob() public {
        vm.prank(freelancer);
        c.applyToJob(testJobID);
        assertTrue(true, "The test has executed successfully");
    }

    function testApplyToExpiredJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", block.timestamp + 1 days);

        vm.warp(block.timestamp + 1 days);

        vm.prank(freelancer);
        try c.applyToJob(testJobID + 1) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The specified job's deadline is expired");
        }
    }

    function testApplyToInvalidJob() public {
        vm.prank(freelancer);
        try c.applyToJob(0) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The specified job does not exists");
        }
    }

    function testApplyToNotOpenJob() public {
        vm.prank(client);
        c.approveFreelancer(testJobID, freelancer);

        vm.prank(freelancer);
        try c.applyToJob(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The specified job cannot be applied to");
        }
    }

    function testApplicantIsClient() public {
        vm.prank(client);
        try c.applyToJob(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "A client cannot apply to its own job");
        }
    }

    function testApproveFreelancer() public {
        vm.prank(client);
        c.approveFreelancer(testJobID, freelancer);

        (, , , , , , , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Assigned), "The job should be in the Assigned state");
    }

    function testFreelancerAlreadyApproved() public {
        testApproveFreelancer();

        vm.prank(client);
        try c.approveFreelancer(testJobID, freelancer) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "Cannot approve more than one freelancer for a job");
        }
    }

    function testApproveExpiredJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", block.timestamp + 1 days);

        vm.warp(block.timestamp + 1 days);

        vm.prank(freelancer);
        try c.approveFreelancer(testJobID + 1, freelancer) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The specified job's deadline is expired");
        }
    }

    function testApproveInvalidJob() public {
        vm.prank(client);
        try c.approveFreelancer(0, freelancer) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The specified job does not exists");
        }
    }

    function testApproveNotClient() public {
        vm.prank(freelancer);
        try c.approveFreelancer(testJobID, freelancer) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The user is not the job's client");
        }
    }

}

contract SubmitTests is PlatformTest {

    function setUp() public override {
        super.setUp();

        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", 4000000000);

        vm.prank(client);
        c.approveFreelancer(testJobID, freelancer);
    }

    function testSubmitWork() public {
        vm.prank(freelancer);
        c.submitWork(testJobID);

        (, , , , , , , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Submitted), "The job should be in the Submitted state");
    }

    function testSubmitExpiredJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", block.timestamp + 1 days);

        vm.warp(block.timestamp + 1 days);

        vm.prank(freelancer);
        try c.submitWork(testJobID + 1) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The specified job's deadline is expired");
        }
    }
    
    function testSubmitAsNotFreelancer() public {
        vm.prank(client);
        try c.submitWork(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "You are not assigned to this job");
        }
    }

    function testSubmitToNotAssignedJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", block.timestamp + 1 days);

        vm.prank(freelancer);
        try c.submitWork(testJobID + 1) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The job hasn't been assigned yet");
        }
    }

}

contract ApprovalTests is PlatformTest {

    function setUp() public override {
        super.setUp();

        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", 4000000000);

        vm.prank(client);
        c.approveFreelancer(testJobID, freelancer);

        vm.prank(freelancer);
        c.submitWork(testJobID);
    }

    function testApprovePayment() public {
        vm.prank(client);
        c.approvePayment(testJobID);

        (, , , , , , , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Completed), "The job should be in the Completed state");
    }

    function testApproveAsFreelancer() public {
        vm.prank(freelancer);
        try c.approvePayment(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The user is not the job's client");
        }
    }

    function testApproveNotSubmittedJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", block.timestamp + 1 days);

        vm.prank(client);
        try c.approvePayment(testJobID + 1) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "Nothing has been submitted yet");
        }
    }

}

contract DisputeTests is PlatformTest {

    function setUp() public override {
        super.setUp();

        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", 4000000000);

        vm.prank(client);
        c.approveFreelancer(testJobID, freelancer);

        vm.prank(freelancer);
        c.submitWork(testJobID);
    }

    function testOpenDispute() public {
        vm.prank(client);
        c.openDispute(testJobID);

        (, , , , , , , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Disputed), "The job should be in the Disputed state");
    }

    function testDisputeOnUnsubmittedJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", block.timestamp + 1 days);

        vm.prank(client);
        try c.openDispute(testJobID + 1) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "Nothing has been submitted yet");
        }
    }

    function testDisputeAsExternalUser() public {
        vm.prank(other);
        try c.openDispute(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The user must be the job's client or freelancer");
        }
    }

    function testSettle(bool isClient) public {
        vm.prank(client);
        c.openDispute(testJobID);

        (, address client, address freelancer, , , uint payment, , ) = c.jobs(testJobID);
        address recipient = isClient ? client : freelancer;
        uint prevBalance = recipient.balance;

        vm.prank(owner);
        c.settle(testJobID, isClient);

        (, , , , , , , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Settled), "The job should be in the Settled state");
        assertEq(recipient.balance, prevBalance + payment, "The recipient has not received the payment");
    }

    function testSettleAsNotMod() public {
        vm.prank(client);
        c.openDispute(testJobID);

        vm.prank(client);
        try c.settle(testJobID, true) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The user is not a moderator");
        }
    }

    function testSettleAnUndisputedJob() public {
        vm.prank(owner);
        try c.settle(testJobID, true) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The job is not being disputed");
        }
    }

}