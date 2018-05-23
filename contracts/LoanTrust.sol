pragma solidity ^0.4.21; 

import './LoanTime.sol';

/**
 * @title LoanTrust
 * @dev Contract handling logic to calculate trust score of a given borrower
 */
contract LoanTrust is LoanTime {
  /**
  * @dev Calculates trust score for borrowers by interfacing with a custom Loan 
  *      Trust instance component which will be used to determine their 
  *      interest payment
  * @param _address Address of individual being checked
  */ 
  function getTrustScore(address _address) external view returns (uint) {
  	return trustInstanceContract.getTrustScore(_address);
  }

  // NOTE: Possible future additions: modifiers for min trust score?

}