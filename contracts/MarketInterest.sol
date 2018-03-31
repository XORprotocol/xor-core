pragma solidity ^0.4.18;

import './MarketTime.sol';

contract MarketInterest is MarketTime {

  function getTrustScore(address _address) public view returns (uint) {
    uint repaymentLength = repayments[_address].length;
    uint defaultLength = defaults[_address].length;
    uint totalRepayments = 10;
    uint totalDefaults;
    for (uint x = 0; x < repaymentLength; x++) {
      totalRepayments = totalRepayments.add(log(repayments[_address][x]));
    }
    for (uint y = 0; y < defaultLength; y++) {
      totalDefaults = totalDefaults.add(defaults[_address][y]);
    }
    return (totalRepayments - totalDefaults);
  }

  function getRisk(address _address, uint _amt) public view returns (uint) {
    return _amt.div(getTrustScore(_address));       
  }

  function getInterest(address _address, uint _amt, uint _marketId) public view returns (uint) {
    return getRisk(_address, _amt).mul(markets[_marketId].riskConstant);
  }

  function addToRepayments(address _address, uint _amt) public {
    repayments[_address].push(_amt);
  }

  function addToDefaults(address _address, uint _amt) public {
    defaults[_address].push(_amt);
  }
}
