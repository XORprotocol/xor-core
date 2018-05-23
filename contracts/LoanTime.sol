ragma solidity ^0.4.21; 

import 'xor-libraries/contracts/XorMath.sol';
import './LoanIdentity.sol';

/**
  * @title LoanTime
  * @dev Contract handling logic involving the four periods/states a loan can be in.
          ie. Request, Loan, Settlement, Collection
 */

contract LoanTime is LoanIdentity {
  using XorMath for uint;
  using SafeMath for uint;

  /** 
   * @dev Returns true if laon is currently in Request Period, false otherwise
   */
  function checkRequestPeriod() public view returns (bool) {
    uint start = updatedAt;
    uint end = requestPeriodEnd();
    if (block.timestamp >= start && block.timestamp <= end) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Returns true if loan is currently in Loan Period, false otherwise
   */
  function checkLoanPeriod() public view returns (bool) {
    uint start = requestPeriodEnd();
    uint end = loanPeriodEnd();
    if (block.timestamp >= start && block.timestamp <= end) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Returns true if loan is currently in Settlement Period, false otherwise
   */
  function checkSettlementPeriod() public view returns (bool) {
    uint start = loanPeriodEnd();
    uint end = settlementPeriodEnd();
    if (block.timestamp >= start && block.timestamp <= end) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Returns true if loan is currently in Collection Period, false otherwise
   */
  function checkCollectionPeriod() public view returns (bool) {
    uint start = settlementPeriodEnd();
    if (block.timestamp >= start) {
      return true;
    } else {
      return false;
    }
  }

  /** 
   * @dev Computes time (in Unix Epoch Time) at which Request Period for loan ends
   */
  function requestPeriodEnd() private view returns (uint) {
    return (updatedAt).add(requestPeriod);
  }

  /** 
   * @dev Computes time (in Unix Epoch Time) at which Lending Period for loan ends
   */
  function loanPeriodEnd() private view returns (uint) {
    return requestPeriodEnd().add(loanPeriod);
  }

  /** 
   * @dev Computes time (in Unix Epoch Time) at which Request Period for loan ends
   */
  function settlementPeriodEnd() private view returns (uint) {
    return loanPeriodEnd().add(settlementPeriod);
  }

  /** 
   * @dev Fectches the current period of the loan
   */
  function getPeriod() public view returns (bytes32) {
    if (checkRequestPeriod()) {
      return "request";
    } else if (checkLoanPeriod()) {
      return "loan";
    } else if (checkSettlementPeriod()) {
      return "settlement";
    } else {
      return "collection";
    }
  }

  /*** MODIFIERS ***/
  /**  
   * @dev Throws if loan is not currently in "Request Period"
   */
  modifier isRequestPeriod() {
    require(checkRequestPeriod());
    _;
  }

  /** 
   * @dev Throws if loan is not currently in "Loan Period"
   */
  modifier isLoanPeriod() {
    require(checkLoanPeriod());
    _;
  }

  /**
   * @dev Throws if loan is not currently in "Settlement Period"
   */
  modifier isSettlementPeriod() {
    require(checkSettlementPeriod());
    _;
  }

  /**
   * @dev Throws if loan is not currently in "Collection Period"
   */
  modifier isCollectionPeriod() {
    require(checkCollectionPeriod());
    _;
  }
  
  /**
   * @dev Throws if loan is before the end of "Request Period"
   */
  modifier isAfterRequestPeriod() {
    require(block.timestamp >= requestPeriodEnd());
    _;
  }
}
