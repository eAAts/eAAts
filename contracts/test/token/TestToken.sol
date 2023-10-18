// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor() ERC20("Test Token", "TT") {}

    function mint(address receiver, uint256 _amount) external {
        _mint(receiver, _amount);
    }
}
