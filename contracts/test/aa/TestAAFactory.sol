// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./TestAA.sol";
import "../interfaces/ITestAAFactory.sol";

contract TestAAFactory {
    bytes32 private constant INIT_CODE_HASH = keccak256(type(TestAA).creationCode);

    mapping(address => address) private _aas;

    function createAA(address owner) external returns (address aa) {
        bytes32 salt = keccak256(abi.encode(owner));
        bytes memory bytecode = type(TestAA).creationCode;
        assembly {
            aa := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        _aas[owner] = aa;
    }

    function getAccountAbstraction(
        address owner
    ) external view returns (address aa) {
        aa = _aas[owner];
    }
}
