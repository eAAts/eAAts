// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IAAController.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract eAAts is Ownable {
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
    function getOrdersByStatus(
        DeliveryStatus _status
    ) external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 1; i <= orderCount; i++) {
            if (orders[i].status == _status) {
                count++;
            }
        }

        uint256[] memory orderIds = new uint256[](count);
        uint256 index = 0;
        for (uint256 j = 1; j <= orderCount; j++) {
            if (orders[j].status == _status) {
                orderIds[index] = j;
                index++;
            }
        }

        return orderIds;
    }
}
