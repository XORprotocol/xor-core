pragma solidity ^0.4.18;

import './MarketTrust.sol';

/**
  * @title MarketInterest
  * @dev Contract handling logic to calculate interest payment for a given borrower in a
         given market
    @notice Mechanism to calculate interest payments:

 */

contract MarketInterest is MarketTrust {

  /*** SETTERS ***/
  /** 
  * @dev Adds repayment amount (in Wei) to repayments array of borrower
  * @param _amt The size of repayment in the previous loan transaction being added
  */
  function addToRepayments(address _address, uint _amt) internal {
    repayments[_address].push(_amt);
  }

  /** 
  @dev Adds default amount (in Wei) to defaults array of borrower
  @param _amt The size of repayment in the previous loan transaction being added
  */
  function addToDefaults(address _address, uint _amt) internal {
    defaults[_address].push(_amt);
  }

  /*** GETTERS & CALCULATIONS ***/
  /**
  * @dev Simple custom calculation of risk factor for an individual borrower
  * @param _amt The amount being requested by borrower in current loan request
  */
  function getRisk(address _address, uint _amt, uint _marketId) private view returns (uint) {
    return _amt.div(getTrustScore(_marketId, _address));       
  }

  /**
  * @dev Simple custom calculation of interest payment for an individual borrower
  * @param _amt The amount being requested by borrower in current loan request
  */
  function getInterest(address _address, uint _amt, uint _marketId) public view returns (uint) {
    return getRisk(_address, _amt, _marketId).mul(markets[_marketId].riskConstant);
  }

  /*** MODIFIERS ***/
  /** 
  * @dev Throws if said borrower currently has trust score of zero
  */
  modifier aboveMinTrust(address _address, uint _amt, uint _marketId) {
    require(getTrustScore(_marketId, _address) > 0);
    _;
  }
}