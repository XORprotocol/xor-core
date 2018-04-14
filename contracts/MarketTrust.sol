pragma solidity ^0.4.18; 

import './MarketTime.sol';

/**
 * @title MarketTrustInterface
 * @dev Interface for custom contracts calculating trust score
 */

contract MarketTrustInterface {
  /**
  * @dev Calculates trust score for borrowers which will be used to determine
  *      their risk factor and rate of interest
  * @param _address Address of individual being checked
  */ 
  function getTrustScore(address _address) public view returns (uint);
}

/**
 * @title MarketTrust
 * @dev Contract handling logic to calculate trust score of a given borrower
 */
contract MarketTrust is MarketTime {
  MarketTrustInterface trustContract;
  
  /**
  * @dev Calculates trust score for borrowers by interfacing with a custom Market 
  *      Trust Contract which will be used to determine their risk factor and 
  *      rate of interest
  * @param _address Address of individual being checked
  */ 
  function getTrustScore(uint _marketId, address _address) public view returns (uint) {
    Market storage curMarket = markets[_marketId];
  	trustContract = MarketTrustInterface(curMarket.trustContractAddress);
  	return trustContract.getTrustScore(_address);
  }

}