// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IeAAts {
    // Enumerations
    enum DeliveryStatus {
        BeforeDelivery,
        DuringDelivery,
        AfterDelivery
    }

    enum FeeType {
        Equal,
        Proportional
    }

    // Structs
    struct Order {
        address[] participants;
        mapping(address => uint256) userAmounts;
        uint256 totalAmount;
        uint256 minParticipants;
        FeeType feeType;
        DeliveryStatus status;
    }

    struct OrderData {
        address[] participants;
        uint256 totalAmount;
        uint256 minParticipants;
        FeeType feeType;
        DeliveryStatus status;
    }

    // Events
    event OrderCreated(
        uint256 indexed orderId,
        address indexed creator,
        uint256 minParticipants,
        FeeType feeType
    );
    event OrderJoined(
        uint256 indexed orderId,
        address indexed participant,
        uint256 amount
    );
    event OrderDeliveryStarted(uint256 indexed orderId);
    event DeliveryCompleted(uint256 indexed orderId);

    function createOrder(
        uint256 _minParticipants,
        FeeType _feeType
    ) external returns (uint256);

    function joinOrder(uint256 _orderId, uint256 _amount) external;

    function completeDelivery(uint256 _orderId) external;

    function getOrdersByStatus(
        DeliveryStatus _status
    ) external view returns (OrderData[] memory);
}
