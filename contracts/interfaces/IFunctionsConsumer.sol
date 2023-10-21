// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Chainlink Functions example on-demand consumer contract example
 */
interface IFunctionsConsumer {
    enum Location {
        Inline, // Provided within the Request
        Remote, // Hosted through remote location that can be accessed through a provided URL
        DONHosted // Hosted on the DON's storage
    }

    function sendRequest(
        string calldata source,
        bytes calldata encryptedSecretsUrls,
        uint8 donHostedSecretsSlotID,
        uint64 donHostedSecretsVersion,
        string[] calldata args,
        bytes[] calldata bytesArgs,
        uint64 subscriptionId,
        uint32 gasLimit
    ) external;
}
