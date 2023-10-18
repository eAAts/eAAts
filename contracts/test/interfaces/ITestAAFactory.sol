// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ITestAAFactory {
    function createAA(address owner) external returns (address aa);

    function getAccountAbstraction(
        address owner
    ) external view returns (address aa);
}
