pragma solidity ^0.4.18;

import "./libraries/PermissionsLib.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Heritable.sol";

contract LoanMarket is Heritable,  {
  using SafeMath for uint;

  struct Market {
    uint requestPeriod; // in blocks
    uint votingPeriod; // in blocks
    uint loanPeriod; // in blocks
    uint totalLoaned;
    uint totalRequested;
    uint initiationTimestamp; // time in blocks of first loan request or offer
    bytes32 state; // request, voting, lending, reconciliation
    uint riskRating; // as voted by lenders
    address[] lenders;
    address[] borrowers;
    mapping (address => uint) lenderAmounts;
    mapping (address => uint) borrowerAmounts;
  }
  
  Market[] public markets;

  function createMarket(uint _requestPeriod, uint _votingPeriod, uint _loanPeriod) public returns (uint) {
    address[] memory lenders;
    address[] memory borrowers;
    markets.push(Market(_requestPeriod, _votingPeriod, _loanPeriod, block.number, "request", 0, lenders, borrowers));
    return markets.length;
  }

  function offerLoan(uint _marketId) public payable {
    Market curMarket = markets[marketId];
    require(curMarket.state == "request");
    if (!checkRequestPeriod(_marketId)) {
      throw;
    } else {
      curMarket.lenders.push(msg.sender);
      curMarket.lenderAmounts[msg.sender] = msg.value;
      curMarket.totalLoaned += msg.value;
    }
  }

  function requestLoan(uint _marketId, uint _amount) public {
    Market curMarket = markets[marketId];
    require(curMarket.state == "request");
    if (!checkRequestPeriod(_marketId)) {
      throw;
    } else {
      curMarket.borrowers.push(msg.sender);
      curMarket.borrowerAmounts[msg.sender] = _amount;
      curMarket.totalRequested += _amount;
    }
  }

  /* TODO:
  function transferExcess
        curMarket.state = 'voting';
  */

  /* START - Check Time Period Helpers */
  function checkRequestPeriod(uint _marketId) private returns (bool) {
    uint start = markets[_marketId].initiationTimestamp;
    uint end = requestPeriodEnd(_marketId);
    if (block.number >= start && block.number <= end) {
      return true;
    } else {
      return false;
    }
  }

  function checkVotingPeriod(uint _marketId) private returns (bool) {
    uint start = requestPeriodEnd(_marketId);
    uint end = votingPeriodEnd(_marketId);
    if (block.number >= start && block.number <= end) {
      return true;
    } else {
      return false;
    }
  }

  function checkLoanPeriod(uint _marketId) private returns (bool) {
    uint start = votingPeriodEnd(_marketId);
    uint end = loanPeriodEnd(uint _marketId);
    if (block.number >= start && block.number <= end) {
      return true;
    } else {
      return false;
    }
  }
  /* END - Check Time Period Helpers */

  function requestPeriodEnd(uint _marketId) private returns (uint) {
    return (markets[_marketId].initiationTimestamp + markets[_marketId].requestPeriod);
  }

  function votingPeriodEnd(uint _marketId) private returns (uint) {
    return (requestPeriodEnd(_marketId) + markets[_markedId].votingPeriod);
  }

  function lendingPeriodEnd(uint _marketId) private returns (uint) {
    return (votingPeriodEnd(_marketId) + markets[_marketId].loanPeriod);
  }


}

  