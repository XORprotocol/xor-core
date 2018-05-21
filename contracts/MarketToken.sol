pragma solidity ^0.4.21;

import "./MarketBase.sol";


contract MarketTokenInterface {

  function createDOT(string _name, string _symbol, uint _cap) public returns(address);
}

/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
 */

contract MarketToken is MarketBase {
  MarketTokenInterface marketTokenContract;


  function setMarketTokenContractAddress(address _address) external onlyOwner {
    marketTokenContract = MarketTokenInterface(_address);
  }

  function getMarketTokenContractAddress() external view returns(address) {
    return address(marketTokenContract);
  }

}
