// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IAutomationCompatible.sol";
import "./interfaces/IeAAts.sol";
import "./interfaces/IFunctionsConsumer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract eAAts is IeAAts, IAutomationCompatible, Ownable {
    // State Variables
    IFunctionsConsumer public consumer;
    uint64 public subscriptionId;
    string public source;
    mapping(uint256 => Order) public orders;
    uint256 public orderCount = 0;
    address public tokenAddress;
    uint256 public deliveryFee;

    event OrderPendingPayment(
        uint256 indexed orderId,
        address indexed user,
        uint256 amount,
        uint256 networkId
    );

    struct PendingPayment {
        uint256 orderId;
        address user;
        uint256 amount;
    }

    PendingPayment[] public pendingPayments;

    // Constructor
    constructor(
        IFunctionsConsumer _consumer,
        uint64 _subscriptionId,
        string memory _source,
        address _tokenAddress,
        uint256 _deliveryFee
    ) {
        consumer = _consumer;
        subscriptionId = _subscriptionId;
        source = _source;

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
     * @param _networkId Network ID to check
     */
    function joinOrder(
        uint256 _orderId,
        uint256 _amount,
        uint256 _networkId
    ) external {
        require(_amount > 0, "Amount must be greater than zero");

        Order storage order = orders[_orderId];
        order.participants.push(msg.sender);
        order.userAmounts[msg.sender] = _amount;
        order.totalAmount += _amount;

        if (_networkId == block.chainid) {
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            );
        } else {
            pendingPayments.push(
                PendingPayment({
                    orderId: _orderId,
                    user: msg.sender,
                    amount: _amount
                })
            );

            emit OrderPendingPayment(_orderId, msg.sender, _amount, _networkId);
        }

        emit OrderJoined(_orderId, msg.sender, _amount);

        if (order.participants.length == order.minParticipants) {
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
                    userAddress,
                    address(this),
                    amount
                );
            } else if (order.feeType == FeeType.Proportional) {
                address userAddress = order.participants[i];
                uint256 amount = (deliveryFee *
                    order.userAmounts[userAddress]) / order.totalAmount;
                IERC20(tokenAddress).transferFrom(
                    userAddress,
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

    function checkUpkeep(
        bytes calldata
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = pendingPayments.length > 0;
        if (upkeepNeeded) {
            PendingPayment memory firstPendingPayment = pendingPayments[0];
            performData = abi.encode(
                firstPendingPayment.user,
                tokenAddress,
                firstPendingPayment.amount
            );
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        (, address token, uint256 amount) = abi.decode(
            performData,
            (address, address, uint256)
        );

        string[] memory args = new string[](3);
        args[0] = addressToString(token);
        args[1] = uint256ToString(amount);
        args[2] = uint256ToString(block.chainid);

        bytes[] memory bytesArgs = new bytes[](0);

        consumer.sendRequest(
            source,
            new bytes(0),
            0,
            0,
            args,
            bytesArgs,
            subscriptionId,
            300000,
            0x66756e2d706f6c79676f6e2d6d61696e6e65742d310000000000000000000000
        );
    }

    function addressToString(
        address _addr
    ) public pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function uint256ToString(uint256 _i) public pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}
