pragma solidity ^0.4.21; 

import './MarketBorrow.sol';

/**
  * @title MarketCore
  * @dev This is the main XOR Market contract, 
  *      keeps track of all the XOR Markets in existence.
 */

contract MarketCore is MarketBorrow {

  /**
   * @dev A public method that creates a new market and stores it.
   */
  function createMarket(uint _requestPeriod, uint _loanPeriod, uint _settlementPeriod, 
    address[] _contractAddressesArray) external returns (uint)
  {
    require(_requestPeriod > 0 && _loanPeriod > 0 && _settlementPeriod > 0
      && _contractAddressesArray.length == 3);
    _createMarket(_requestPeriod, _loanPeriod, _settlementPeriod, _contractAddressesArray);
  }

  /**
   * @dev A public method that creates a new market version and stores it.
   */
  function createMarketVersion(uint _marketId, uint _requestPeriod, uint _loanPeriod, 
    uint _settlementPeriod, address[] _contractAddressesArray) external returns (uint)
  {
    require(_marketId >= 0 && _marketId <= getCurVersionNumber(_marketId) && 
      _requestPeriod > 0 && _loanPeriod > 0 && _settlementPeriod > 0
      && _contractAddressesArray.length == 3);
    _createMarketVersion(_marketId, _requestPeriod, _loanPeriod, _settlementPeriod, 
      _contractAddressesArray);
  }

  /**
   * @dev A public function that retrieves the number of markets currently on XOR
   */
  function getMarketCount() external view returns (uint) {
    return markets.length;
  }

}
