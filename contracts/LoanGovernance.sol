pragma solidity ^0.4.21;

import "./LoanBase.sol";


/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
 */
contract LoanGovernance is LoanBase {

  function createGovernance() public {
    governanceContract.createGovernance();
  }

  function getGenesisProtocolContractAddress() public returns(address) {
    return governanceContract.getGenesisProtocolContractAddress();
  }

  function getDOTTokenAddress() public view returns(address) {
    return address(dotContract);
  }
}
