// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./PlatformTestBase.sol";

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