// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {BulkSender} from "@contracts/BulkSender.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import {TokenERC20} from "./utils/TokenERC20.sol";

contract ContractTest is Test {
    uint256 mainnetFork;

    string internal constant MAINNET_FORK_URL =
        "https://eth.getblock.io/cd527522-6486-4d11-9c35-b9f498dd0e9c/mainnet/";

    BulkSender bulkSender;
    TokenERC20 token;

    //impersonating this address, setting to admin
    address public defaultAdmin = 0x266fedED59399AFC982EEa44724fCa7Ba31C054f;

    function setUp() public {
        vm.createFork(MAINNET_FORK_URL);
        vm.selectFork(mainnetFork);

        vm.startPrank(defaultAdmin);

        //instatiate contracts
        bulkSender = new BulkSender();
        token = new TokenERC20("Test", "TST");
        vm.stopPrank();
    }

    function testInMainnetFork() public {
        assertEq(vm.activeFork(), mainnetFork);
    }

    function testbatchTransfer() public {
        vm.startPrank(defaultAdmin);

        //initialize the defaultAdmin as the admin of the bulkSender
        bulkSender.initialize(defaultAdmin);

        //assert that the balance of the default is 0 before transfer of tokens to it
        assertEq(token.balanceOf(address(defaultAdmin)), 0);
        token.mintTo(address(defaultAdmin), 1000000000000000000);

        //assert that the balance of the defaultAdmin is 1000000000000000000 after transfer of tokens to it
        assertEq(token.balanceOf(address(defaultAdmin)), 1000000000000000000);

        //approve the bulkSender to spend the tokens
        token.approve(address(bulkSender), 1000000000000000000);

        address[] memory to = new address[](2);
        to[0] = 0x8A9c4dfe8b9D8962B31e4e16F8321C44d48e246E;
        to[1] = 0x11eDedebF63bef0ea2d2D071bdF88F71543ec6fB;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10000000;
        amounts[1] = 10000000;

        bulkSender.batchTransfer(IERC20Upgradeable(token), to, amounts);
        vm.stopPrank();
    }

    function testwithdrawToken() public {
        vm.startPrank(defaultAdmin);

        //initialize the defaultAdmin as the admin of the bulkSender
        bulkSender.initialize(defaultAdmin);

        //assert that the balance of the bulkSender is 0 before transfer od tokens to it
        assertEq(token.balanceOf(address(bulkSender)), 0);
        token.mintTo(address(bulkSender), 1000);

        //assert that after trasfering tokens to the bulksender the balance is 1000
        assertEq(token.balanceOf(address(bulkSender)), 1000);

        //withdraw the tokens from the bulkSender
        bulkSender.widthrawToken(IERC20Upgradeable(token), 500);

        //assert that after withdrawing 500 tokens the balance is 500 for buksender contract
        assertEq(token.balanceOf(address(bulkSender)), 500);

        //assert that the balance of the default admin is 500
        assertEq(token.balanceOf(defaultAdmin), 500);

        vm.stopPrank();
    }

    function testInitialize() public {
        vm.startPrank(defaultAdmin);
        bulkSender.initialize(defaultAdmin);
        vm.stopPrank();
    }

    function testOwner() public {
        vm.startPrank(defaultAdmin);
        bulkSender.initialize(defaultAdmin);

        bytes32 expected = keccak256(abi.encodePacked(defaultAdmin));

        assertEq(
            bulkSender.hasRole(bulkSender.DEFAULT_ADMIN_ROLE(), defaultAdmin),
            true
        );

        vm.stopPrank();
    }
}
