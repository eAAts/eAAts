// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/ITestAA.sol";

contract TestAA is ITestAA {
    receive() external payable {}

    function run(
        address targetAddress,
        uint256 value,
        bytes memory messageBody
    ) external {
        (bool success, ) = address(targetAddress).call{value: value}(
            messageBody
        );
        require(success, "AA::run: Execution failed");
    }
}
