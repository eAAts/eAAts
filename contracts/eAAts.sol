// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IAAController.sol";
import "./interfaces/IeAAts.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract eAAts is IeAAts, Ownable {
    // State Variables
    mapping(uint256 => Order) public orders;
    IAAController public aaController;
    uint256 public orderCount = 0;
    address public tokenAddress;
    uint256 public deliveryFee;

    // Constructor
    constructor(
        IAAController _aaController,
        address _tokenAddress,
        uint256 _deliveryFee
    ) {
        aaController = _aaController;
        tokenAddress = _tokenAddress;
        deliveryFee = _deliveryFee;
    }

    // External Functions

    /**
     * @notice Creates a new order
     * @param _minParticipants Minimum number of participants required for the order
     * @param _feeType Fee type of the order
     * @return The ID of the created order
     */
    function createOrder(
        uint256 _minParticipants,
        FeeType _feeType
    ) external returns (uint256) {
        require(
            _minParticipants > 0,
            "Minimum participants should be greater than 0"
        );
        require(
            (_feeType == FeeType.Equal) || (_feeType == FeeType.Proportional),
            "Invalid FeeType"
        );

        orderCount++;

        Order storage newOrder = orders[orderCount];
        newOrder.participants = new address[](0);
        newOrder.totalAmount = 0;
        newOrder.minParticipants = _minParticipants;
        newOrder.feeType = _feeType;
        newOrder.status = DeliveryStatus.BeforeDelivery;

        emit OrderCreated(orderCount, msg.sender, _minParticipants, _feeType);

        return orderCount;
    }

    /**
     * @notice Allows a user to join an order
     * @param _orderId ID of the order to join
     * @param _amount Amount to contribute to the order
     */
    function joinOrder(uint256 _orderId, uint256 _amount) external {
        require(
            aaController.getAccountAbstraction(msg.sender) != address(0),
            "Invalid account abstraction"
        );

        Order storage order = orders[_orderId];
        order.participants.push(msg.sender);
        order.userAmounts[msg.sender] = _amount;
        order.totalAmount += _amount;

        emit OrderJoined(_orderId, msg.sender, _amount);

        if (order.participants.length == order.minParticipants) {
            for (uint256 i = 0; i < order.participants.length; i++) {
                address userAddress = order.participants[i];
                IERC20(tokenAddress).transferFrom(
                    aaController.getAccountAbstraction(userAddress),
                    address(this),
                    order.userAmounts[userAddress]
                );
            }
            order.status = DeliveryStatus.DuringDelivery;

            emit OrderDeliveryStarted(_orderId);
        }
    }

    /**
     * @notice Marks an order as completed (delivery done)
     * @param _orderId ID of the order to complete
     */
    function completeDelivery(uint256 _orderId) external onlyOwner {
        Order storage order = orders[_orderId];
        require(
            order.status == DeliveryStatus.DuringDelivery,
            "Order is not in the delivery process or already delivered."
        );

        for (uint256 i = 0; i < order.participants.length; i++) {
            if (order.feeType == FeeType.Equal) {
                address userAddress = order.participants[i];
                uint256 amount = deliveryFee / order.minParticipants;
                IERC20(tokenAddress).transferFrom(
                    aaController.getAccountAbstraction(userAddress),
                    address(this),
                    amount
                );
            } else if (order.feeType == FeeType.Proportional) {
                address userAddress = order.participants[i];
                uint256 amount = (deliveryFee *
                    order.userAmounts[userAddress]) / order.totalAmount;
                IERC20(tokenAddress).transferFrom(
                    aaController.getAccountAbstraction(userAddress),
                    address(this),
                    amount
                );
            }
        }

        order.status = DeliveryStatus.AfterDelivery;

        emit DeliveryCompleted(_orderId);
    }

    // View Functions

    /**
     * @notice Fetches orders based on their delivery status
     * @param _status Desired delivery status
     * @return An array of orders matching the provided status
     */
    function getOrdersByStatus(
        DeliveryStatus _status
    ) external view returns (OrderData[] memory) {
        // Counting the orders with the given status
        uint256 count = 0;
        for (uint256 i = 1; i <= orderCount; i++) {
            if (orders[i].status == _status) {
                count++;
            }
        }

        // Collecting the orders
        OrderData[] memory matchedOrders = new OrderData[](count);
        uint256 index = 0;
        for (uint256 j = 1; j <= orderCount; j++) {
            if (orders[j].status == _status) {
                matchedOrders[index] = OrderData(
                    orders[j].participants,
                    orders[j].totalAmount,
                    orders[j].minParticipants,
                    orders[j].feeType,
                    orders[j].status
                );
                index++;
            }
        }

        return matchedOrders;
    }
}
