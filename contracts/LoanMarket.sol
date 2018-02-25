pragma solidity ^0.4.18;

import './zeppelin/lifecycle/Killable.sol';

contract LoanMarket is Killable {

  struct Market {
    uint requestPeriod; // in seconds
    uint loanPeriod; // in seconds
    mapping (address => uint) lenderAmounts;
    address[] lenders;
    mapping (address => uint) borrowerAmounts;
    address[] borrowers;
  }
  
  struct LoanData {
    uint amount;
    address user;
  }
  
  Market[] public markets;

  function createMarket(uint _requestPeriod, uint _loanPeriod) public {  
    address[] memory lenders;
    address[] memory borrowers;
    markets.push(Market(_requestPeriod, _loanPeriod, lenders, borrowers));
  }
}
  