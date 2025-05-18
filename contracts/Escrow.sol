// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EscrowManager {
    struct Trade {
        address buyer;
        address seller;
        uint256 amount;
        bool isDeposited;
        bool isReleased;
    }

    mapping(uint256 => Trade) public trades;
    uint256 public tradeCounter;

    event TradeCreated(uint256 tradeId, address buyer, address seller, uint256 amount);
    event TradeReleased(uint256 tradeId, address to);
    event TradeRefunded(uint256 tradeId, address to);

    /// @notice Create a new trade by depositing ETH and assigning a seller
    function createTrade(address _seller) external payable {
        require(msg.value > 0, "Must send ETH");
        require(_seller != address(0), "Invalid seller");

        trades[tradeCounter] = Trade({
            buyer: msg.sender,
            seller: _seller,
            amount: msg.value,
            isDeposited: true,
            isReleased: false
        });

        emit TradeCreated(tradeCounter, msg.sender, _seller, msg.value);

        tradeCounter++;
    }

    /// @notice Buyer releases funds to the seller
    function release(uint256 _tradeId) external {
        Trade storage trade = trades[_tradeId];

        require(msg.sender == trade.buyer, "Only buyer can release");
        require(trade.isDeposited, "No funds to release");
        require(!trade.isReleased, "Already released");

        trade.isReleased = true;
        trade.isDeposited = false;
        payable(trade.seller).transfer(trade.amount);

        emit TradeReleased(_tradeId, trade.seller);
    }

    /// @notice Seller refunds the trade to the buyer
    function refund(uint256 _tradeId) external {
        Trade storage trade = trades[_tradeId];

        require(msg.sender == trade.seller, "Only seller can refund");
        require(trade.isDeposited, "No funds to refund");
        require(!trade.isReleased, "Already released");

        trade.isDeposited = false;
        payable(trade.buyer).transfer(trade.amount);

        emit TradeRefunded(_tradeId, trade.buyer);
    }
}
