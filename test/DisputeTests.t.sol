// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./PlatformTestBase.sol";

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
