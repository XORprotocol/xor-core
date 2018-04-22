pragma solidity ^0.4.23; 

import './MarketTrust.sol';

/**
 * @title MarketInterestInterface
 * @dev Interface for custom contracts calculating interest
 */

contract MarketInterestInterface {
  /**
   * @dev Calculates interest payment for borrowers
   * @param _address Address of individual being checked
   * @param _amt The amount being requested by borrower in current market
   */ 
  function getInterest(uint _marketId, address _address, uint _amt) public view returns (uint);
}


/**

 * @title MarketInterest
 * @dev Contract handling logic to calculate interest for a given borrower
 */
contract MarketInterest is MarketTrust {
  MarketInterestInterface interestContract;
  /**
  * @dev Calculates interest payment for borrowers by interfacing with a custom Market 
  *      Interest Contract
  * @param _address Address of individual being checked
  * @param _amt The amount being requested by borrower in current market
  */
  function getInterest(uint _marketId, address _address, uint _amt) public view returns (uint) {
    Market storage curMarket = markets[_marketId];
    interestContract = MarketInterestInterface(curMarket.interestContractAddress);
    return interestContract.getInterest(_marketId, _address, _amt);
  }

  /*** MODIFIERS ***/
  /** 
  * @dev Throws if said borrower currently has trust score of zero
  */
  modifier aboveMinTrust(address _address, uint _marketId) {
    require(getTrustScore(_marketId, _address) > 0);
    _;
  }
}