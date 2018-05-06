pragma solidity ^0.4.21;

import './DOT.sol';

contract DOTFactory {
	mapping(address => address[]) public created;
	mapping(address => bool) public isDOT;

	function createDOT(string _name, string _symbol, uint _decimals) public returns(address) {
		DOT newToken = (new DOT(_name, _symbol, _decimals));
		created[msg.sender].push(address(newToken));
		isDOT[address(newToken)] = true;

		return address(newToken);
	}
}