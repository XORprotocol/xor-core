pragma solidity ^0.4.18;

// import "./libraries/PermissionsLib.sol";
// import "zeppelin-solidity/contracts/math/SafeMath.sol";
// import "zeppelin-solidity/contracts/ownership/Heritable.sol";
// import "daostack-arc/contracts/VotingMachines/QuorumVote.sol";

contract LoanMarket {
  // using SafeMath for uint;
  // using PermissionsLib for PermissionsLib.Permissions;
  Market[] public markets;
  
  struct Market {
    uint requestPeriod; // in blocks
    uint votingPeriod; // in blocks
    uint loanPeriod; // in blocks
    uint totalLoaned;
    uint totalRequested;
    uint initiationTimestamp; // time in blocks of first loan request or offer
    uint riskRating; // as voted by lenders
    bytes32 state; // request, voting, lending, reconciliation
    address[] lenders;
    address[] borrowers;
    mapping (address => uint) lenderAmounts;
    mapping (address => uint) borrowerAmounts;
  }
  
  function getMarket(uint _marketId) public view returns(uint,uint,uint,uint,uint,uint,uint,bytes32,address[],address[]) {
    Market memory curMarket = markets[_marketId];
    return (
      curMarket.requestPeriod,
      curMarket.votingPeriod,
      curMarket.loanPeriod,
      curMarket.totalLoaned,
      curMarket.totalRequested,
      curMarket.initiationTimestamp,
      curMarket.riskRating,
      curMarket.state,
      curMarket.lenders,
      curMarket.borrowers
      );
  }

  function getLender(uint _marketId, uint _lenderId) public view returns(address, uint) {
    Market storage curMarket = markets[_marketId];
    address lender = curMarket.lenders[_lenderId];
    uint lenderAmount = curMarket.lenderAmounts[lender];
    return (lender, lenderAmount);
  }

  function getBorrower(uint _marketId, uint _borrowerId) public view returns(address, uint) {
    Market storage curMarket = markets[_marketId];
    address borrower = curMarket.borrowers[_borrowerId];
    uint borrowerAmount = curMarket.borrowerAmounts[borrower];
    return (borrower, borrowerAmount);
  }

  function getMarketCount() public view returns (uint) {
    return markets.length;
  }

  // TODO: getter for lenderAmt and borrowerAmt
  
  function createMarket(uint _requestPeriod, uint _votingPeriod, uint _loanPeriod) public returns (uint) {
    address[] memory lenders;
    address[] memory borrowers;
    markets.push(Market(_requestPeriod, _votingPeriod, _loanPeriod, 0, 0, block.number, 0, "request", lenders, borrowers));
    return markets.length;
  }

  function offerLoan(uint _marketId) public payable {
    Market storage curMarket = markets[_marketId];
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
    Market storage curMarket = markets[_marketId];
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
    uint end = lendingPeriodEnd(_marketId);
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
    return (requestPeriodEnd(_marketId) + markets[_marketId].votingPeriod);
  }

  function lendingPeriodEnd(uint _marketId) private returns (uint) {
    return (votingPeriodEnd(_marketId) + markets[_marketId].loanPeriod);
  }

  function vote(uint _marketId, uint choice) {
    // require in correct Period
    markets[_marketId].riskRating = choice;
  }

}