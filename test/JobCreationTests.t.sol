// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "./PlatformTestBase.sol";

contract JobCreationTests is PlatformTest {

    function testCreateJob() public {
        vm.prank(client);
        c.createJob{value: 100}("Test", "A test", 4000000000);

        (, , , , , , JobState state) = c.jobs(testJobID);
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
