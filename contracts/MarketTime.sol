pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './libraries/XorMath.sol';
import './MarketIdentity.sol';

/**
  * @title MarketTime
  * @dev Contract handling logic involving the four periods/states a market can be in.
          ie. Request, Loan, Settlement, Collection
 */

contract MarketTime is MarketIdentity {
  using XorMath for uint;
  using SafeMath for uint;

  /** 
   * @dev Returns true if market is currently in Request Period, false otherwise
   */
  function checkRequestPeriod(uint _marketId) public view returns (bool) {
    uint start = markets[_marketId].initiationTimestamp;
    uint end = requestPeriodEnd(_marketId);
    if (block.timestamp >= start && block.timestamp <= end) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Returns true if market is currently in Loan Period, false otherwise
   */
  function checkLoanPeriod(uint _marketId) public view returns (bool) {
    uint start = requestPeriodEnd(_marketId);
    uint end = lendingPeriodEnd(_marketId);
    if (block.timestamp >= start && block.timestamp <= end) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Returns true if market is currently in Settlement Period, false otherwise
   */
  function checkSettlementPeriod(uint _marketId) public view returns (bool) {
    uint start = lendingPeriodEnd(_marketId);
    uint end = settlementPeriodEnd(_marketId);
    if (block.timestamp >= start && block.timestamp <= end) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Returns true if market is currently in Collection Period, false otherwise
   */
  function checkCollectionPeriod(uint _marketId) public view returns (bool) {
    uint start = settlementPeriodEnd(_marketId);
    if (block.timestamp >= start) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Computes time (in Unix Epoch Time) at which Request Period for market ends
   */
  function requestPeriodEnd(uint _marketId) private view returns (uint) {
    return markets[_marketId].initiationTimestamp.add(markets[_marketId].requestPeriod);
  }

  /** 
   * @dev Computes time (in Unix Epoch Time) at which Lending Period for market ends
   */
  function lendingPeriodEnd(uint _marketId) private view returns (uint) {
    return requestPeriodEnd(_marketId).add(markets[_marketId].loanPeriod);
  }

  /** 
   * @dev Computes time (in Unix Epoch Time) at which Request Period for market ends
   */
  function settlementPeriodEnd(uint _marketId) private view returns (uint) {
    return lendingPeriodEnd(_marketId).add(markets[_marketId].settlementPeriod);
  }

  /** 
   * @dev Fectches the current period of the market
   */
  function getMarketPeriod(uint _marketId) public view returns (bytes32) {
    if (checkRequestPeriod(_marketId)) {
      return "request";
    } else if (checkLoanPeriod(_marketId)) {
      return "loan";
    } else if (checkSettlementPeriod(_marketId)) {
      return "settlement";
    } else {
      return "collection";
    }
  }

  /*** MODIFIERS ***/
  /**  
   * @dev Throws if market is not currently in "Request Period"
   */
  modifier isRequestPeriod(uint _marketId) {
    require(checkRequestPeriod(_marketId));
    _;
  }

  /** 
   * @dev Throws if market is not currently in "Loan Period"
   */
  modifier isLoanPeriod(uint _marketId) {
    require(checkLoanPeriod(_marketId));
    _;
  }

  /**
   * @dev Throws if market is not currently in "Settlement Period"
   */
  modifier isSettlementPeriod(uint _marketId) {
    require(checkSettlementPeriod(_marketId));
    _;
  }

  /**
   * @dev Throws if market is not currently in "Collection Period"
   */
  modifier isCollectionPeriod(uint _marketId) {
    require(checkCollectionPeriod(_marketId));
    _;
  }
  
  /**
   * @dev Throws if market is before the end of "Request Period"
   */
  modifier isAfterRequestPeriod(uint _marketId) {
    require(block.timestamp >= requestPeriodEnd(_marketId));
    _;
  }
}
