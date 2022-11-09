// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {BulkSender} from "@contracts/BulkSender.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract ContractTest is Test {
    uint256 mainnetFork;
    string internal constant MAINNET_FORK_URL =
        "https://eth.getblock.io/cd527522-6486-4d11-9c35-b9f498dd0e9c/mainnet/";

    BulkSender bulkSender;

    //variables for testing
    address public defaultAdmin = 0x266fedED59399AFC982EEa44724fCa7Ba31C054f;
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        vm.createFork(MAINNET_FORK_URL);
        vm.selectFork(mainnetFork);

        vm.startPrank(defaultAdmin);
        bulkSender = new BulkSender();
        vm.stopPrank();
    }

    function testInMainnetFork() public {
        assertEq(vm.activeFork(), mainnetFork);
    }

    function testBatchTransfer() public {
        vm.startPrank(defaultAdmin);

        address[] memory to = new address[](2);
        to[0] = 0x8A9c4dfe8b9D8962B31e4e16F8321C44d48e246E;
        to[1] = 0x11eDedebF63bef0ea2d2D071bdF88F71543ec6fB;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1000000000000000000;
        amounts[1] = 1000000000000000000;

        bulkSender.batchTransfer(IERC20Upgradeable(WETH), to, amounts);
        vm.stopPrank();
    }

    function testWithdrawToken() public {
        vm.startPrank(defaultAdmin);
        bulkSender.widthrawToken(IERC20Upgradeable(WETH), 1000000000000000000);
        // bulkSender.withdrawToken(IERC20Upgradeable(WETH), 1000000000000000);
        vm.stopPrank();
    }

    // function testOwner() public {
    //     assertEq(bulkSender.owner(), defaultAdmin);
    // }
}
