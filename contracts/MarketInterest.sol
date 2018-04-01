pragma solidity ^0.4.18;

import './MarketTime.sol';

/**
  * @title MarketInterest
  * @dev Contract handling logic to calculate interest payment for a given borrower in a
         given market
    @notice Mechanism to calculate interest payments:

 */

contract MarketInterest is MarketTime {

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
  * @dev Custom calculation of trust score for an individual borrower using square roots 
  */
  function getTrustScore(address _address) public view returns (uint) {
    uint numRepayments = repayments[_address].length;
    uint numDefaults = defaults[_address].length;

    // total value of all repayments in Wei
    uint totalRepayments;

    // total value of all defaults in Wei
    uint totalDefaults;

    // numerator of calculation
    uint repaymentComponent;

    // denominator of calculation
    uint defaultComponent;

    uint score;

    for (uint x = 0; x < numRepayments; x++) {
      totalRepayments = totalRepayments.add(repayments[_address][x]);
    }
    for (uint y = 0; y < numDefaults; y++) {
      totalDefaults = totalDefaults.add(defaults[_address][y]);
    }

    repaymentComponent = totalRepayments.sqrt().div(100000000);

    // @note Calculation below gives defaults 1.25 weight relative to repayments of the same size
    defaultComponent = totalDefaults.sqrt().div(80000000);

    // Base trust score of 20, which is added to repaymentComponent and subtracted by defaultComponent
    score = repaymentComponent.add(20).sub(defaultComponent);
    // TODO: catch throw when score negative

    return score;
  }

  /**
  * @dev Simple custom calculation of risk factor for an individual borrower
  * @param _amt The amount being requested by borrower in current loan request
  */
  function getRisk(address _address, uint _amt) private view returns (uint) {
    return _amt.div(getTrustScore(_address));       
  }

  /**
  * @dev Simple custom calculation of interest payment for an individual borrower
  * @param _amt The amount being requested by borrower in current loan request
  */
  function getInterest(address _address, uint _amt, uint _marketId) public view returns (uint) {
    return getRisk(_address, _amt).mul(markets[_marketId].riskConstant);
  }

  /*** MODIFIERS ***/
  /** 
  * @dev Throws if said borrower currently has trust score of zero
  */
  modifier aboveMinTrust(address _address, uint _amt, uint _marketId) {
    require(getTrustScore(_address) > 0);
    _;
  }
}
