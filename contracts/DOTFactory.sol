pragma solidity ^0.4.21;

import './DOT.sol';
import './StringUtils.sol';


contract ExampleMarketTokenInterface {

  // Address from MarketCore
  // function getDOTTokenAddress(uint _marketId) public returns(address);
}

contract DOTFactory {
	ExampleMarketTokenInterface marketTokenContract;

	mapping(address => address[]) public created;
	mapping(address => bool) public isDOT;

	function createDOT(string _name, string _symbol, uint _cap) public returns(address) {
		DOT newToken = (new DOT(_name, _symbol, _cap));
		created[msg.sender].push(address(newToken));
		isDOT[address(newToken)] = true;

		return address(newToken);
	}

	function getMarketStrId(uint _marketId) public returns(bytes32) {
		return StringUtils.uintToBytes(_marketId);
	}

	/**
    * @dev Set the address of the sibling contract that tracks trust score.
   */
  function setMarketTokenContractAddress(address _address) external {
    marketTokenContract = ExampleMarketTokenInterface(_address);
  }

  /**
    * @dev Get the address of the sibling contract that tracks trust score.
   */
  function getMarketGovernanceContractAddress() external view returns(address) {
    return address(marketTokenContract);
  }
}
