pragma solidity ^0.4.21;

import './DOTFactory.sol';
import 'openzeppelin-solidity/contracts/lifecycle/Destructible.sol';

/**
  * @title MarketTrustInterface
  * @dev Interface for XOR Market Trust Contract for calculating trust score
 */

contract ExampleMarketTokenInterface {

  // Address from MarketCore
}


/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
 */

contract ExampleMarketToken is Destructible {
  ExampleMarketTokenInterface exampleMarketTokenContract;

  /**
    * @dev Set the address of the sibling contract that tracks trust score.
   */
  function setMarketGovernanceContractAddress(address _address) external onlyOwner {
    exampleMarketTokenContract = ExampleMarketTokenInterface(_address);
  }

  /**
    * @dev Get the address of the sibling contract that tracks trust score.
   */
  function getMarketTokenContractAddress() external view returns(address) {
    return address(exampleMarketTokenContract);
  }
}
