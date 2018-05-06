pragma solidity ^0.4.4;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

/*
 * DOT
 *
 * Very simple ERC20 Token example, where all tokens are pre-assigned
 * to the creator. Note they can later distribute these tokens
 * as they wish using `transfer` and other `StandardToken` functions.
 */
contract DOT is StandardToken {

  string public name;
  string public symbol;
  uint public decimals;

  function DOT(string _name, string _symbol, uint _decimals) {
	name = _name;
	symbol = _symbol;
	decimals = _decimals;
    totalSupply_ = 0;
    balances[msg.sender] = 0;
  }

}
