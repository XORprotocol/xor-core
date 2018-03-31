pragma solidity ^0.4.18;

import './MarketInterest.sol';

contract MarketLend is MarketInterest {

  function getLender(uint _marketId, address _lender) public view returns(uint, uint, uint, uint ,uint) {
    uint actualOffer = actualLenderOffer(_lender, _marketId);
    return (
      getLenderOffer(_marketId, _lender), 
      actualOffer, 
      getLenderCollected(_marketId, _lender), 
      getLenderCollectible(_lender, _marketId), 
      percent(actualOffer, marketPool(_marketId), 5)
    );
  }

  function getLenderIndex(uint _marketId, address _lenderAddress) public view returns (uint) {
    uint index = 0;
    for (uint i = 0; i < getLenderCount(_marketId); i++) {
      if (markets[_marketId].lenders[i] == _lenderAddress) {
        index = i;
      }
    }
    return index;
  }

  function getLenderCount(uint _marketId) public view returns (uint) {
    return markets[_marketId].lenders.length;
  }

  function getLenderCollected(uint _marketId, address _address) public view returns (uint) {
    return markets[_marketId].lenderCollected[_address];
  }

  function getLenderOffer(uint _marketId, address _address) public view returns (uint) {
    return markets[_marketId].lenderOffers[_address];
  }

  function isLender(uint _marketId, address _address) public view returns (bool) {
    if (markets[_marketId].lenderOffers[_address] > 0) {
        return true;
    } else {
        return false;
    }
  }

  function getLenderAddress(uint _marketId, uint _lenderId) public view returns (address) {
    return markets[_marketId].lenders[_lenderId];
  }

  function offerLoan(uint _marketId) public payable {
    Market storage curMarket = markets[_marketId];
    require(curMarket.state == "request");
    // if (!checkRequestPeriod(_marketId)) {
    //   throw;
    // } else {
      curMarket.lenders.push(msg.sender);
      curMarket.lenderOffers[msg.sender] = msg.value;
      curMarket.totalLoaned = curMarket.totalLoaned.add(msg.value);
    // }
  }

  function calculateExcess(uint _marketId, address _address) public view returns (uint) {
    if (markets[_marketId].totalLoaned > markets[_marketId].totalRequested) {
      uint curValue = 0;
      for (uint i = 0; i < getLenderCount(_marketId); i++) {
        if (markets[_marketId].lenders[i] == _address) {
          if (curValue < markets[_marketId].totalRequested) {
            uint newValue = curValue.add(markets[_marketId].lenderOffers[_address]);
            if (newValue > markets[_marketId].totalRequested) {
              uint diff = markets[_marketId].totalRequested.sub(curValue);
              return markets[_marketId].lenderOffers[_address].sub(diff);
            } else {
              return 0;
            }
          }
          break;
        }
        curValue = curValue.add(markets[_marketId].lenderOffers[markets[_marketId].lenders[i]]);
      }
    } else {
      return 0;
    }
  }

  // Lenders removing excess from market
  function transferExcess(uint _marketId) public {
    require(checkLoanPeriod(_marketId));
    require(markets[_marketId].lenderOffers[msg.sender] > 0);
    msg.sender.transfer(calculateExcess(_marketId, msg.sender));
  }

  function actualLenderOffer(address _address, uint _marketId) public view returns (uint) {
    return markets[_marketId].lenderOffers[_address].sub(calculateExcess(_marketId, _address));
  }

  function getLenderCollectible(address _address, uint _marketId) public view returns (uint) {
    return actualLenderOffer(_address, _marketId).mul(markets[_marketId].curRepaid).div(marketPool(_marketId));
  }

  function withdrawCollected(uint _marketId) public {
    // require lending period over
    msg.sender.transfer(getLenderCollectible(msg.sender, _marketId));
  }

}