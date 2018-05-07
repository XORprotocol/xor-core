pragma solidity ^0.4.21; 

import './MarketTime.sol';

/**
 * @title MarketTrustInterface
 * @dev Interface for custom contracts calculating trust score
 */

contract MarketTrustInterface {
  /**
  * @dev Calculates trust score for borrowers which will be used to determine
  *      their interest payment
  * @param _address Address of individual being checked
  */ 
  function getTrustScore(address _address) external view returns (uint);
}


/**
 * @title MarketTrust
 * @dev Contract handling logic to calculate trust score of a given borrower
 */
contract MarketTrust is MarketTime {
  MarketTrustInterface trustInstanceContract;
  
  function setTrustContractAddress(uint _marketId) external {
    trustInstanceContract = MarketTrustInterface(getMarketTrustContract(_marketId));
  }
  /**
  * @dev Calculates trust score for borrowers by interfacing with a custom Market 
  *      Trust Contract which will be used to determine their interest payment
  * @param _address Address of individual being checked
  */ 
  function getTrustScore(address _address) external view returns (uint) {
  	return trustInstanceContract.getTrustScore(_address);
  }

  // NOTE: Possible future additions: modifiers for min trust score?

}