// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./PlatformTestBase.sol";

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
