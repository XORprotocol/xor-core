pragma solidity ^0.4.21;

import "./MarketIdentity.sol";
// import './DOTFactory.sol';


contract MarketGovernanceInterface {
  /**
   * @dev Calculates interest payment for borrowers
   */
  function createGovernance( uint _marketId, address _tokenAddress);
}

/**
 * @title MarketIdentity
 * @dev Contract used to determine unique identity of actors on protocol
 * NOTE: Each actor must be verified using some identity
 */
contract MarketGovernance is MarketIdentity {

  MarketGovernanceInterface governanceContract;


  function createGovernance(uint _marketId, address _token) public {
    Market storage curMarket = markets[_marketId];
    governanceContract = MarketGovernanceInterface(curMarket.governanceContractAddress);
    governanceContract.createGovernance(_marketId, _token);
  }

}
