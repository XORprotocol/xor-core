pragma solidity ^0.4.21;

import "./MarketBase.sol";

/**
  * @title MarketTrustInterface
  * @dev Interface for XOR Market Trust Contract for calculating trust score
 */

contract MarketTokenInterface {

  // Address from MarketCore
  function createDOT(string _name, string _symbol, uint _decimals) public returns(address);
}


/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
 */

contract MarketToken is MarketBase {
  MarketTokenInterface marketTokenContract;

  /**
    * @dev Set the address of the sibling contract that tracks trust score.
   */
  function setMarketTokenContractAddress(address _address) external onlyOwner {
    marketTokenContract = MarketTokenInterface(_address);
  }

  /**
    * @dev Get the address of the sibling contract that tracks trust score.
   */
  function getMarketTokenContractAddress() external view returns(address) {
    return address(marketTokenContract);
  }

}
