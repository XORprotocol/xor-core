pragma solidity ^0.4.21;

import "./MarketToken.sol";


contract MarketGovernanceInterface {

  function createDOTUsingMarketId(uint _marketId) public;
  function createGovernance(uint _marketId);
  function getDOTTokenAddress() public view returns(address);
  function getGenesisProtocolContractAddress() external view returns(address);
}

/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
 */
contract MarketGovernance is MarketToken {

  function getMarketGovernance(uint _marketId) public view returns(MarketGovernanceInterface) {
    return MarketGovernanceInterface(getMarketGovernanceContract(_marketId));
  }

  function createDOTUsingMarketId(uint _marketId) public {
    getMarketGovernance(_marketId).createDOTUsingMarketId(_marketId);
  }

  function createGovernance(uint _marketId) public {
    getMarketGovernance(_marketId).createGovernance(_marketId);
  }

  function getDOTTokenAddress(uint _marketId) public view returns(address) {
    return getMarketGovernance(_marketId).getDOTTokenAddress();
  }
}
