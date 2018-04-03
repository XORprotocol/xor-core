pragma solidity ^0.4.18;

import "./MarketBase.sol";

/**
 * @title MarketIdentity
 * @dev Contract used to determine unique identity of actors on protocol
 * NOTE: Each actor must be verified using some identity
 */
contract MarketIdentity is MarketBase {

  mapping (address => uint[]) repayments;
  mapping (address => uint[]) defaults;
  
  /**
   * @dev Retreives an array of repayments (and the size of each repayment)
   *      for a particular borrower
   */
  function getRepayments(address _address) public view returns (uint[]) {
  	return repayments[_address];
  } 

  /**
   * @dev Retrieves an array of defaults (and the size of each default)
   *      for a particular borrower
   */
  function getDefaults(address _address) public view returns (uint[]) {
  	return defaults[_address];
  }

  /**
   * @dev Retrieves the number of repayments
   */
  function getRepaymentsLength(address _address) public view returns (uint) {
  	return repayments[_address].length;
  }

  /**
   * @dev Retrieves the number of defaults
   */
  function getDefaultsLength(address _address) public view returns (uint) {
  	return defaults[_address].length;
  }
}