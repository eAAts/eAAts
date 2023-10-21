// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title IeAAts
 * @notice Interface for the eAAts contract
 */
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

    /**
     * @notice Creates a new order
     * @param _minParticipants Minimum number of participants required for the order
     * @param _feeType Fee type of the order
     * @return The ID of the created order
     */
    function createOrder(
        uint256 _minParticipants,
        FeeType _feeType
    ) external returns (uint256);

    /**
     * @notice Allows a user to join an order
     * @param _orderId ID of the order to join
     * @param _amount Amount to contribute to the order
     * @param _networkId Network ID to check
     */
    function joinOrder(
        uint256 _orderId,
        uint256 _amount,
        uint256 _networkId
    ) external;

    /**
     * @notice Marks an order as completed (delivery done)
     * @param _orderId ID of the order to complete
     */
    function completeDelivery(uint256 _orderId) external;

    /**
     * @notice Fetches orders based on their delivery status
     * @param _status Desired delivery status
     * @return An array of orders matching the provided status
     */
    function getOrdersByStatus(
        DeliveryStatus _status
    ) external view returns (OrderData[] memory);
}
