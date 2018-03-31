pragma solidity ^0.4.18;

import './MarketCreation.sol';

contract MarketTime is MarketCreation {

  function checkRequestPeriod(uint _marketId) public returns (bool) {
    uint start = markets[_marketId].initiationTimestamp;
    uint end = requestPeriodEnd(_marketId);
    if (block.number >= start && block.number <= end) {
      return true;
    } else {
      return false;
    }
  }

  function checkLoanPeriod(uint _marketId) public returns (bool) {
    uint start = requestPeriodEnd(_marketId);
    uint end = lendingPeriodEnd(_marketId);
    if (block.number >= start && block.number <= end) {
      return true;
    } else {
      return false;
    }
  }

  function checkReconciliationPeriod(uint _marketId) public returns (bool) {
    uint start = lendingPeriodEnd(_marketId);
    if (block.number >= start) {
      return true;
    } else {
      return false;
    }
  }

  function requestPeriodEnd(uint _marketId) private returns (uint) {
    return (markets[_marketId].initiationTimestamp + markets[_marketId].requestPeriod);
  }

  function lendingPeriodEnd(uint _marketId) private returns (uint) {
    return (requestPeriodEnd(_marketId) + markets[_marketId].loanPeriod);
  }

}

