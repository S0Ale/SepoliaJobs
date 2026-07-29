// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./PlatformTestBase.sol";

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
