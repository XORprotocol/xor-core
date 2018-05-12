pragma solidity ^0.4.21; 

import "./MarketBase.sol";

/**
 * @title MarketIdentity
 * @dev Contract used to determine unique identity of actors on protocol
 * NOTE: Each actor must be verified using some identity
 */
contract MarketIdentity is MarketBase {

  mapping (address => uint[]) repayments;
  mapping (address => uint[]) defaults;
  
  /*** SETTERS ***/
  /** 
   * @dev Adds repayment amount (in Wei) to repayments array of borrower
   * @param _amt The size of repayment in the previous loan transaction being added
   */
  function addToRepayments(address _address, uint _amt) internal {
    repayments[_address].push(_amt);
  }

  /** 
   * @dev Adds default amount (in Wei) to defaults array of borrower
   * @param _amt The size of repayment in the previous loan transaction being added
   * NOTE: Not yet called
   */
  function addToDefaults(address _address, uint _amt) internal {
    defaults[_address].push(_amt);
  }

  /*** GETTERS ***/
  /**
   * @dev Given the address, return the repayment at a specific index
   */
  function getRepayment(address _address, uint _index) external view returns (uint) {
    return repayments[_address][_index];
  }

  /**
   * @dev Given the address, return the default at a specific index
   */
  function getDefault(address _address, uint _index) external view returns (uint) {
    return defaults[_address][_index];
  }

  /**
   * @dev Retrieves the number of repayments
   */
  function getRepaymentsLength(address _address) external view returns (uint) {
    return repayments[_address].length;
  }

  /**
   * @dev Retrieves the number of defaults
   */
  function getDefaultsLength(address _address) external view returns (uint) {
    return defaults[_address].length;
  }
}
