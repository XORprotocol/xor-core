pragma solidity ^0.4.21; 

import './LoanTrust.sol';

/**
 * @title MarketInterest
 * @dev Contract handling logic to calculate interest for a given borrower
 */
contract LoanInterest is LoanTrust {
  /**
  * @dev Calculates interest payment for borrowers by interfacing with a custom Market 
  *      Interest Contract
  * @param _address Address of individual being checked
  * @param _amt The amount being requested by borrower in current market
  */
  function getInterest(address _address, uint _amt) public view returns (uint) {
    return interestInstanceContract.getInterest(_address, _amt);
  }
}