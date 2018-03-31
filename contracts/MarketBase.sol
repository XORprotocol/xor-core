pragma solidity ^0.4.18;

/// @title Base contract for CryptoKitties. Holds all common structs, events and base variables.
contract MarketBase {
  /*** EVENTS ***/
  event NewMarket(uint marketId);
  /*** DATA TYPES ***/
  // An array containing all markets on XOR protocol
  Market[] public markets;
  
  struct Market {
    uint requestPeriod; // in blocks
    uint loanPeriod; // in blocks
    uint settlementPeriod; // in blocks
    uint totalLoaned; // size of lending pool put forward by lenders 
    uint totalRequested; // value of total amount requested by borrowers
    uint curBorrowed; // amount taken out by borrowers at a given time
    uint curRepaid; // amount repaid by borrowers at a given time
    uint initiationTimestamp; // time in blocks of first loan request or offer
    uint riskConstant; // Interest = riskOfBorrower * riskConstant
    address[] lenders; // array of all lenders participating in the market
    address[] borrowers; // array of all borrowers participating in the market
    mapping (address => uint) lenderOffers; 
    mapping (address => uint) borrowerRequests;
    mapping (address => uint) lenderCollected; // stores amount that each lender has collected back from loans
    mapping (address => uint) borrowerWithdrawn; // stores amount that each borrower has withdrawn from their loan
    mapping (address => uint) borrowerRepaid;
  }

  /// @dev A mapping from market ID to the address that created them. 
  mapping (uint256 => address) public marketIndexToMaker;

  /// @dev An internal method that creates a new market and stores it. This
  ///  method doesn't do any checking and should only be called when the
  ///  input data is known to be valid
  function createMarket(uint _requestPeriod, uint _loanPeriod, uint _settlementPeriod, uint _riskConstant) internal returns (uint) {
    address[] memory _lenders;
    address[] memory _borrowers;
    uint newId = markets.push(Market(_requestPeriod, _loanPeriod, _settlementPeriod, 0, 0, 0, 0, 
      block.number, _riskConstant, _lenders, _borrowers)) - 1;
    marketIndexToMaker[newId] = msg.sender;
    NewMarket(newId);
    return newId;
  }

  function marketPool(uint _marketId) internal view returns (uint) {
    Market memory curMarket = markets[_marketId];
    if (curMarket.totalLoaned >= curMarket.totalRequested) {
      return curMarket.totalRequested;
    } else {
      return curMarket.totalLoaned;
    }
  }
}
