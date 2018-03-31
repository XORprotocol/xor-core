pragma solidity ^0.4.18;

import "./MarketBase.sol";

contract MarketIdentity is MarketBase {

  mapping (address => uint[]) repayments;
  mapping (address => uint[]) defaults;
  
}