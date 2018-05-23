pragma solidity ^0.4.21; 

import 'openzeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract LoanFactoryInterface {
  // returns address of loan created (the contract)
  function createLoan(uint[] _periodArray, 
    address[] _contractAddressesArray) public returns(address);
}
/**
  * @title MarketBase
  * @dev Base contract for XOR Markets. Holds all common structs, events and base variables
 */

contract MarketBase is Destructible {

  /*** EVENTS ***/
  /**
   * @dev Triggered when a new market has been created.
   * NOTE: Might not be necessary
   */
  event NewMarket(uint marketId);

  /**
   * @dev Triggered when a new version of a market has been launched.
   */
  // event NewMarketVersion(uint marketId, uint latestVersion);
  
  /*** DATA TYPES ***/
  struct Market {
    
    // Time in Linux Epoch Time of Market creation
    uint createdAt; 
    
    // Latest version number of Market
    uint curVersion;

    // A mapping of all loan versions in existence of the market. The versionNum is 
    // is the uint mapped to each Version. Initial version is 0. 

    mapping(uint => address) loans;
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
  mapping (uint => address) public marketIndexToMaker;

  LoanFactoryInterface loanFactoryContract;

  function setLoanFactoryContractAddress(address _address) external {
    loanFactoryContract = LoanFactoryInterface(_address);
  }
  /** 
   * @dev An external method that creates a new Market and stores it. This
   *      method doesn't do any checking and should only be called when the
   *      input data is known to be valid. Takes parameters corresponding to 
   *      Version 0 of Market being created.
   * @param _contractAddressesArray An array containing the addresses of instance
   *                               component contracts
   *                               [governance, trust, interest]
   * @return MarketId of Market created, which is index of created Market within markets
   *         array
   */
  function createMarket(uint[] _periodArray, 
    address[] _contractAddressesArray) public returns (uint) {
    require(_periodArray.length == 3 && _periodArray[0] > 0
      && _periodArray[1] > 0 && _periodArray[2] > 0 &&
      _contractAddressesArray.length == 3);
    uint curMarketVer = 0;
    uint newMarketId = markets.push(Market(block.timestamp, curMarketVer)) - 1;
    loanFactoryContract.createLoan(_periodArray, _contractAddressesArray);
    marketIndexToMaker[newMarketId] = msg.sender;
    emit NewMarket(newMarketId);
    return newMarketId;
  }

  /*** MODIFIERS ***/
  modifier validMarketId(uint _marketId) {
    require(_marketId < markets.length);
    _;
  }
}
