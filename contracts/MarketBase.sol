pragma solidity ^0.4.21; 

import 'openzeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

/**
  * @title MarketBase
  * @dev Base contract for XOR Markets. Holds all common structs, events and base variables
 */

contract MarketBase is Destructible {
using SafeMath for uint;
  /*** EVENTS ***/
  /**
   * @dev Triggered when a new market has been created.
   * NOTE: Might not be necessary
   */
  event NewMarket(uint marketId);

  /**
   * @dev Triggered when a new version of a market has been launched.
   */
  event NewMarketVersion(uint marketId, uint latestVersion);
  
  /*** DATA TYPES ***/
  struct Market {
    
    // Time in Linux Epoch Time of Market creation
    uint createdAt; 
    
    // Latest version number of Market
    uint curVersion;

    // A mapping of all versions in existence of the market. The versionNum is 
    // is the uint mapped to each Version. Initial version is 0. 
    mapping(uint => Version) versions;

  }
 
  struct Version {

    // Time in Linux Epoch Time of Version creation
    uint updatedAt; 

    // Duration of "Request Period" during which borrowers submit loan requests 
    // and lenders offer loans
    uint requestPeriod;
    
    // Duration of "Loan Period" during which the loan is actually taken out
    uint loanPeriod;
    
    // Duration of "Settlement Period" during which borrowers repay lenders
    uint settlementPeriod; 
    
    // @notice Reason "Collection Period" is not a field is because it is infinite
    //         by default. Lenders have an unlimited time period within which
    //         they can collect repayments and interest 

    // Size of lending pool put forward by lenders in market (in Wei)
    uint totalOffered; 

    // Value of total amount requested by borrowers in market (in Wei)
    uint totalRequested; 
    
    // Amount taken out by borrowers on loan at a given time (in Wei)
    uint curBorrowed; 
    
    // Amount repaid by borrowers at a given time (in Wei)
    uint curRepaid;

    // Address of external governance contract
    address governanceContractAddress;

    // Address of external trust contract
    address trustContractAddress;

    // Address of external interest contract
    address interestContractAddress;

    // Array of all lenders participating in the market
    address[] lenders; 
    
    // Array of all borrowers participating in the market
    address[] borrowers; 

    // Mapping of each lender (their address) to the size of their loan offer
    // (in Wei); amount put forward by each lender
    mapping (address => uint) lenderOffers; 
    
    // Mapping of each borrower (their address) to the size of their loan request
    // (in Wei)
    mapping (address => uint) borrowerRequests;
    
    // Mapping of each borrower to amount they have withdrawn from their loan (in Wei)
    mapping (address => uint) borrowerWithdrawn; 
    
    // Mapping of each borrower to amount of loan they have repaid (in Wei)
    mapping (address => uint) borrowerRepaid;

    // Mapping of each lender to amount that they have collected back from loans (in Wei)
    // NOTE: Currently, lenders must collect their entire collectible amount
    //       at once. In future, there are plans to allow lenders to only collect part of 
    //       collectible amount at any one time
    mapping (address => uint) lenderCollected; 
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
   * @dev An internal method that creates a new Market and stores it. This
   *      method doesn't do any checking and should only be called when the
   *      input data is known to be valid. Takes parameters corresponding to 
   *      Version 0 of Market being created.
   * @param _contractAddressesArray An array containing the addresses of instance
   *                               component contracts
   *                               [governance, trust, interest]
   * @return MarketId of Market created, which is index of created Market within markets
   *         array
   */
  function _createMarket(uint _requestPeriod, uint _loanPeriod, uint _settlementPeriod, 
    address[] _contractAddressesArray) internal returns (uint) {
    address[] memory _lenders;
    address[] memory _borrowers;
    uint curMarketVer = 0;
    uint newMarketId = markets.push(Market(block.timestamp, curMarketVer)) - 1;
    Market storage newMarket = markets[newMarketId];
    newMarket.versions[curMarketVer] = Version(block.timestamp, _requestPeriod, _loanPeriod, 
      _settlementPeriod, 0, 0, 0, 0, _contractAddressesArray[0],
      _contractAddressesArray[1], _contractAddressesArray[2], _lenders, _borrowers);
    marketIndexToMaker[newMarketId] = msg.sender;
    emit NewMarket(newMarketId);
    emit NewMarketVersion(newMarketId, 0);
    return newMarketId;
  }

  /**
   * @return VersionNum of Version created, which is uint corresponding to Version within
   *         mapping
   */
  function _createMarketVersion(uint _marketId, uint _requestPeriod, uint _loanPeriod, 
    uint _settlementPeriod, address[] _contractAddressesArray) 
    internal returns (uint) {
    address[] memory _lenders;
    address[] memory _borrowers;
    Market storage curMarket = markets[_marketId];
    curMarket.curVersion = curMarket.curVersion.add(1);
    curMarket.versions[curMarket.curVersion] = Version(block.timestamp, _requestPeriod, 
      _loanPeriod, _settlementPeriod, 0, 0, 0, 0,  _contractAddressesArray[0], 
      _contractAddressesArray[1], _contractAddressesArray[2], _lenders, _borrowers);
    emit NewMarketVersion(_marketId, curMarket.curVersion);
    return curMarket.curVersion;
  }

  /*** OTHER FUNCTIONS ***/

  /**
   * @dev Retrieves all fields/relevant information about current version of a Market
   */
  /*
  function getMarket(uint _marketId) public view 
    returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, address, address, address,
      address[], address[]) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Market memory curMarket = markets[_marketId];
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return (curMarket.createdAt, curMarketVer.updatedAt, curMarketVer.requestPeriod, curMarketVer.loanPeriod,
      curMarketVer.settlementPeriod, curMarketVer.riskCoefficient, curMarketVer.totalOffered,
      curMarketVer.totalRequested, curMarketVer.curBorrowed, curMarketVer.curRepaid,
      curMarketVer.governanceContractAddress, curMarketVer.trustContractAddress, 
      curMarketVer.interestContractAddress, curMarketVer.lenders, curMarketVer.borrowers);
  }

  /**
   * @dev Retrieves all fields/relevant information about a specific version of a Market
   */
  /*
  function getMarketByVersion(uint _marketId, uint _versionNum) public view 
    returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, address, address, address,
      address[], address[]) {
    Market memory queryMarket = markets[_marketId];
    Version memory queryMarketVer = markets[_marketId].versions[_versionNum];
    return (queryMarket.createdAt, queryMarketVer.updatedAt, queryMarketVer.requestPeriod, queryMarketVer.loanPeriod,
      queryMarketVer.settlementPeriod, queryMarketVer.riskCoefficient, queryMarketVer.totalOffered,
      queryMarketVer.totalRequested, queryMarketVer.curBorrowed, queryMarketVer.curRepaid,
      queryMarketVer.governanceContractAddress, queryMarketVer.trustContractAddress, 
      queryMarketVer.interestContractAddress, queryMarketVer.lenders, queryMarketVer.borrowers);
  }*/

  /**
   * @dev Retrieves lastest version number of a given market
   */
  function getCurVersionNumber(uint _marketId) public view returns (uint) {
    return markets[_marketId].curVersion;
  }

  /**
   * @dev Retrieves time at which market was initially created
   */
  function getMarketCreatedAt(uint _marketId) public view returns (uint) {
    return markets[_marketId].createdAt;
  }

  /**
   * @dev Retrieves time at which current version of market began
   */
  function getMarketUpdatedAt(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.updatedAt;
  }

  function getMarketRequestPeriod(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.requestPeriod;
  }

  function getMarketLoanPeriod(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.loanPeriod;
  }

  function getMarketSettlementPeriod(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.settlementPeriod;
  }

  function getMarketTotalOffered(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.totalOffered;
  }

  function getMarketTotalRequested(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.totalRequested;
  }

  function getMarketCurBorrowed(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.curBorrowed;
  }

  function getMarketCurRepaid(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.curRepaid;
  }

  function getMarketGovernanceContract(uint _marketId) public view returns (address) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.governanceContractAddress;
  }

  function getMarketTrustContract(uint _marketId) public view returns (address) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.trustContractAddress;
  }

  function getMarketInterestContract(uint _marketId) public view returns (address) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.interestContractAddress;
  }

  function getMarketLenders(uint _marketId) public view returns (address[]) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.lenders;
  }

  function getMarketBorrowers(uint _marketId) public view returns (address[]) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version memory curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.borrowers;
  }

  /**
   * @dev Retrieves the amount (in Wei) that a lender has offered/deposited into
   *      the market.
   *      Called before Request Period is complete.
   */
  function getLenderOffer(uint _marketId, address _address) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.lenderOffers[_address];
  }

  /**
   * @dev Retrieves the amount (in Wei) that a borrower has requested to loan from
   *      the market.
   *      Called before Request Period is complete.
   */
  function getBorrowerRequest(uint _marketId, address _address) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.borrowerRequests[_address];
  }

  /**
   * @dev Retrieves the amount (in Wei) that a borrower has withdrawn from
   *      the amount they've borrowed
   */
  function getBorrowerWithdrawn(uint _marketId, address _borrower) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.borrowerWithdrawn[_borrower];
  }

  /**
   * @dev Retrieves the amount (in Wei) that a borrower has repaid to cover interest
   *      and principal on their loan
   */
  function getBorrowerRepaid(uint _marketId, address _borrower) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.borrowerRepaid[_borrower];
  }

  /**
   * @dev Retrieves the amount (in Wei) that a lender has collected back from
   *      their loan/investment
   */
  function getLenderCollected(uint _marketId, address _address) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    return curMarketVer.lenderCollected[_address];
  }

  /**
   * @dev A public function that retrieves the size of the getMarketPool actually 
   *      available for loans. Takes the minimum of total amount requested by 
   *      borrowers and total amount offered by lenders
   */
  function getMarketPool(uint _marketId) public view returns (uint) {

    if (getMarketTotalOffered(_marketId) >= getMarketTotalRequested(_marketId)) {
      return getMarketTotalRequested(_marketId);
    } else {
      return getMarketTotalOffered(_marketId);
    }
  }

}
