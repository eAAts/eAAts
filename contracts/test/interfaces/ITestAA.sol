// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ITestAA {
    function run(
        address targetAddress,
        uint256 value,
        bytes memory messageBody
    ) external;
}
