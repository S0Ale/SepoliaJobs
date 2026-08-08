// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./PlatformTestBase.sol";

contract JobCreationTests is PlatformTest {

    function testCreateJob() public {
        uint prevBalance = client.balance;

        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", 4000000000);

        (, , , , uint payment, , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Open), "The job should be in the Open state");
        assertEq(client.balance, prevBalance - payment, "The client's payment has not been deducted from their balance");
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

    function testDeleteJob() public {
        testCreateJob();
        uint prevBalance = client.balance;

        vm.prank(client);
        c.deleteJob(testJobID);

        (, , , , uint payment, , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Deleted), "The job should be in the Deleted state");
        assertEq(client.balance, prevBalance + payment, "The freelancer has not received the refund");
    }

    function testDeleteAsNotClient() public {
        testCreateJob();

        vm.prank(freelancer);
        try c.deleteJob(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The user is not the job's client", "An unknown error occurred");
        }
    }

    function testDeleteAnAssignedJob() public {
        testCreateJob();

        vm.prank(client);
        c.approveFreelancer(testJobID, freelancer);

        vm.prank(freelancer);
        c.submitWork(testJobID);

        vm.prank(client);
        try c.deleteJob(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "An assigned job cannot be deleted", "An unknown error occurred");
        }
    }

    function testRefund() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", block.timestamp + 1 days);

        uint prevBalance = client.balance;
        vm.warp(block.timestamp + 2 days);

        vm.prank(client);
        c.tryRefund(testJobID);

        (, , , , uint payment, , JobState state) = c.jobs(testJobID);
        assertEq(uint(state), uint(JobState.Deleted), "The job should be in the Open state");
        assertEq(client.balance, prevBalance + payment, "The client has not been refunded");
    }

    function testRefundAsNotClient() public {
        testCreateJob();

        vm.prank(freelancer);
        try c.tryRefund(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The user is not the job's client", "An unknown error occurred");
        }
    }

    function testRefundNotExpiredJob() public {
        testCreateJob();

        vm.prank(client);
        try c.tryRefund(testJobID) {
            assertTrue(false, "The call should have failed");
        } catch Error(string memory reason) {
            assertEq(reason, "The specified job's deadline is not expired yet", "An unknown error occurred");
        }
    }

}
