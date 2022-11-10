// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";

contract TokenERC20 is ERC20Upgradeable {
    constructor(string memory name, string memory symbol) ERC20Upgradeable() {}

    function mintTo(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
