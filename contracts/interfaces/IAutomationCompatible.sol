// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IAutomationCompatible {
    function checkUpkeep(
        bytes calldata
    ) external view returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;
}
