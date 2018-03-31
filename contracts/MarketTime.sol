pragma solidity ^0.4.18;

import './MarketIdentity.sol';
import './libraries/XorMath.sol';
import './libraries/SafeMath.sol';

contract MarketTime is MarketIdentity {
  using XorMath for uint;
  using SafeMath for uint;

  function checkRequestPeriod(uint _marketId) public view returns (bool) {
    uint start = markets[_marketId].initiationTimestamp;
    uint end = requestPeriodEnd(_marketId);
    if (block.number >= start && block.number <= end) {
      return true;
    } else {
      return false;
    }
  }

  function checkLoanPeriod(uint _marketId) public view returns (bool) {
    uint start = requestPeriodEnd(_marketId);
    uint end = lendingPeriodEnd(_marketId);
    if (block.number >= start && block.number <= end) {
      return true;
    } else {
      return false;
    }
  }

  function checkSettlementPeriod(uint _marketId) public view returns (bool) {
    uint start = lendingPeriodEnd(_marketId);
    uint end = settlementPeriodEnd(_marketId);
    if (block.number >= start) {
      return true;
    } else {
      return false;
    }
  }

  function requestPeriodEnd(uint _marketId) private view returns (uint) {
    return markets[_marketId].initiationTimestamp.add(markets[_marketId].requestPeriod);
  }

  function lendingPeriodEnd(uint _marketId) private view returns (uint) {
    return requestPeriodEnd(_marketId).add(markets[_marketId].loanPeriod);
  }

  function settlementPeriodEnd(uint _marketId) private view returns (uint) {
    return lendingPeriodEnd(_marketId).add(markets[_marketId].settlementPeriod);
  }

  modifier isRequestPeriod(uint _marketId) {
    require(checkRequestPeriod(_marketId));
    _;
  }

  modifier isLoanPeriod(uint _marketId) {
    require(checkLoanPeriod(_marketId));
    _;
  }

  modifier isSettlementPeriod(uint _marketId) {
    require(checkSettlementPeriod(_marketId));
    _;
  }
}
