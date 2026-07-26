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

    address payable owner;
    address payable client;
    address payable freelancer;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        owner = TestAccounts.getAccount(0);
        client = TestAccounts.getAccount(1);
        freelancer = TestAccounts.getAccount(2);
    }

    //TODO: test the methods using the created account and run tests

}
    