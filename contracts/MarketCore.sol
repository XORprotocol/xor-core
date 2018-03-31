pragma solidity ^0.4.18;

import './MarketBorrow.sol';

contract MarketCore is MarketBorrow {

  function getMarket(uint _marketId)
    public
    view
    returns
  (
    uint,
    uint,
    uint,
    uint,
    uint,
    uint,
    uint,
    uint,
    uint,
    address[],
    address[]
  ) {
    Market memory curMarket = markets[_marketId];
    return (
      curMarket.requestPeriod,
      curMarket.loanPeriod,
      curMarket.settlementPeriod,
      curMarket.totalLoaned,
      curMarket.totalRequested,
      curMarket.curBorrowed,
      curMarket.curRepaid,
      curMarket.initiationTimestamp,
      curMarket.riskConstant,
      curMarket.lenders,
      curMarket.borrowers
    );
  }
}
