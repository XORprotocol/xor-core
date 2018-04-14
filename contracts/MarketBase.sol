pragma solidity ^0.4.18; 

import './zeppelin/lifecycle/Killable.sol';

/**
  * @title MarketBase
  * @dev Base contract for XOR Markets. Holds all common structs, events and base variables
 */

contract MarketBase is Killable {
  /*** EVENTS ***/
  /**
   * @dev Triggered when a new market has been created.
   */
  event NewMarket(uint marketId);
  
  /*** DATA TYPES ***/
  struct Market {
    // Duration of "Request Period" during which borrowers submit loan requests 
    // and lenders offer loans measured in blocks
    uint requestPeriod;
    
    // Duration of "Loan Period" during which the loan is actually taken out
    uint loanPeriod;
    
    // Duration of "Settlement Period" during which borrowers repay lenders
    uint settlementPeriod; 
    
    // @notice Reason "Collection Period" is not a field is because it is infinite
    //         by default. Lenders have an unlimited time period within which
    //         they can collect repayments and interest

    // Size of lending pool put forward by lenders in market (in Wei)
    uint totalLoaned; 
    
    // Value of total amount requested by borrowers in market (in Wei)
    uint totalRequested; 
    
    // Amount taken out by borrowers on loan at a given time (in Wei)
    uint curBorrowed; 
    
    // Amount repaid by borrowers at a given time (in Wei)
    uint curRepaid; 
    
    // Time in Linux Epoch Time of market creation
    uint initiationTimestamp; 
    
    // Risk Coefficient is a coefficient multiplier that is multiplied with
    // the Risk Rating of each borrower to calculate their Interest Payment for
    // current loan (in Wei)
    uint riskConstant; 
    
    // Array of all lenders participating in the market
    address[] lenders; 
    
    // Array of all borrowers participating in the market
    address[] borrowers; 

    // Address of external trust contract
    address trustContractAddress;

    // Address of external interest contract
    address interestContractAddress;
    
    // Mapping of each lender (their address) to the size of their loan offer
    // (in Wei); amount put forward by each lender
    mapping (address => uint) lenderOffers; 
    
    // Mapping of each borrower (their address) to the size of their loan request
    // (in Wei)
    mapping (address => uint) borrowerRequests;
    
    // Mapping of each lender to amount that they have collected back from loans (in Wei)
    // NOTE: Currently, since lenders must collect their entire collectible amount
    //       at once, we need not store the uint amount, could just store a boolean
    //       indicating whether they've collected
    mapping (address => uint) lenderCollected; 
    
    // Mapping of each borrower to amount they have withdrawn from their loan (in Wei)
    mapping (address => uint) borrowerWithdrawn; 
    
    // Mapping of each borrower to amount of loan they have repaid (in Wei)
    mapping (address => uint) borrowerRepaid;
  }

  /*** STORAGE ***/
  /**
   * @dev An array containing all markets in existence. The marketID is
   an index in this array.
   */
  Market[] public markets;
  
  /**
   * @dev A mapping from market ID to the address that created them. 
   */
  mapping (uint256 => address) public marketIndexToMaker;

  /** 
   * @dev An internal method that creates a new market and stores it. This
     method doesn't do any checking and should only be called when the
     nput data is known to be valid
  */
  function _createMarket(uint _requestPeriod, uint _loanPeriod, uint _settlementPeriod, 
    uint _riskConstant, address _trustContractAddress, address _interestContractAddress) internal returns (uint) {
    address[] memory _lenders;
    address[] memory _borrowers;
    uint newId = markets.push(Market(_requestPeriod, _loanPeriod, _settlementPeriod, 0, 0, 0, 0, 
      block.timestamp, _riskConstant, _lenders, _borrowers, _trustContractAddress, _interestContractAddress)) - 1;
    marketIndexToMaker[newId] = msg.sender;
    NewMarket(newId);
    return newId;
  }

  /*** OTHER FUNCTIONS ***/
  /**
   * @dev An internal method that determines the size of the marketPool actually
     available for loans. Takes the minimum of total amount requested by borrowers 
     and total amount offered by lenders
   */
  function _marketPool(uint _marketId) internal view returns (uint) {
    Market memory curMarket = markets[_marketId];
    if (curMarket.totalLoaned >= curMarket.totalRequested) {
      return curMarket.totalRequested;
    } else {
      return curMarket.totalLoaned;
    }
  }
}
