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

  mapping (address => uint[]) repayments;
  mapping (address => uint[]) defaults;

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

  function getMarketByState(bytes32 _state) public view returns (uint[]) {
    uint[] storage ids;
    for (uint i = 0; i < markets.length; i++) {
      if (markets[i].state == _state) {
        ids.push(i);
      }
    }
    return ids;
  }

  // FOR DEBUGGING
  function changeMarketState(uint _marketId, bytes32 _state) public {
      markets[_marketId].state = _state;
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
    // if (!checkRequestPeriod(_marketId)) {
    //   throw;
    // } else {
      curMarket.lenders.push(msg.sender);
      curMarket.lenderAmounts[msg.sender] = msg.value;
      curMarket.totalLoaned += msg.value;
    // }
  }

  function requestLoan(uint _marketId, uint _amount) public {
    Market storage curMarket = markets[_marketId];
    require(curMarket.state == "request");
    // if (!checkRequestPeriod(_marketId)) {
    //   throw;
    // } else {
      curMarket.borrowers.push(msg.sender);
      curMarket.borrowerAmounts[msg.sender] = _amount;
      curMarket.totalRequested += _amount;
    // }
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

  function log(uint x) public view returns (uint y){
    assembly {
      let arg := x
      x := sub(x,1)
      x := or(x, div(x, 0x02))
      x := or(x, div(x, 0x04))
      x := or(x, div(x, 0x10))
      x := or(x, div(x, 0x100))
      x := or(x, div(x, 0x10000))
      x := or(x, div(x, 0x100000000))
      x := or(x, div(x, 0x10000000000000000))
      x := or(x, div(x, 0x100000000000000000000000000000000))
      x := add(x, 1)
      let m := mload(0x40)
      mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
      mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
      mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
      mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
      mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
      mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
      mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
      mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
      mstore(0x40, add(m, 0x100))
      let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
      let shift := 0x100000000000000000000000000000000000000000000000000000000000000
      let a := div(mul(x, magic), shift)
      y := div(mload(add(m,sub(255,a))), shift)
      y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
    }
  }

  function getTrustScore(address _address) public view returns (uint) {
    uint repaymentLength = repayments[_address].length;
    uint defaultLength = defaults[_address].length;
    uint totalRepayments;
    uint totalDefaults;
    for (uint x = 0; x < repaymentLength; x++) {
      totalRepayments += repayments[_address][x];
    }
    for (uint y = 0; y < defaultLength; y++) {
      totalDefaults += defaults[_address][y];
    }
    return (log(totalRepayments) - totalDefaults);
  }

  function addToRepayments(address _address, uint _amt) public {
    repayments[_address].push(_amt);
  }

  function addToDefaults(address _address, uint _amt) public {
    defaults[_address].push(_amt);
  }

  // function getRepaymentAmount(uint _marketId) public view returns (uint) {
  //   require(markets[_marketId].borrowerAmounts[msg.sender] > 0);
  // }

  // function repayment(uint _marketId) public payable {

  // } 
}
