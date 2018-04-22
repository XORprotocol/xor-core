pragma solidity ^0.4.21; 

import './MarketBorrow.sol';

/**
  * @title MarketCore
  * @dev This is the main XOR Market contract, 
  *      keeps track of all the XOR Markets in existence.
 */

contract MarketCore is MarketBorrow {
  /*** GETTERS ***/
  /**
   * @dev Retrieves all fields/relevant information about a Market
   * @param _marketId The ID of the market of interest
   */
  function getMarket(uint _marketId) public view
    returns (
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

  /**
   * @dev A public method that creates a new market and stores it.
   */
  function createMarket(uint _requestPeriod, uint _loanPeriod, uint _settlementPeriod, 
    uint _riskConstant, address _trustContractAddress, address _interestContractAddress) public returns (uint)
  {
    require(_requestPeriod > 0 && _loanPeriod > 0 && _settlementPeriod > 0 && _riskConstant > 0);
    _createMarket(_requestPeriod, _loanPeriod, _settlementPeriod, _riskConstant, _trustContractAddress, _interestContractAddress);
  }

  /**
   * @dev A public function that retrieves the size of the marketPool actually 
   *      available for loans. Takes the minimum of total amount requested by 
   *      borrowers and total amount offered by lenders
   */
  function marketPool(uint _marketId) public view returns (uint) {
    return _marketPool(_marketId);
  }

  /**
   * @dev A public function that retrieves the number of markets currently on XOR
   */
  function getMarketCount() public view returns (uint) {
    return markets.length;
  }

  /**
   * @dev A public function that retreives the risk Constant of a given market
   */
  function getRiskConstant(uint _marketId) public view returns (uint) {
    return markets[_marketId].riskConstant;
  }
}
