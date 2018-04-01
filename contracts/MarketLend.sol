pragma solidity ^0.4.18;

import './MarketInterest.sol';
import './libraries/SafeMath.sol';
import './libraries/XorMath.sol';

contract MarketLend is MarketInterest {
  using XorMath for uint;
  using SafeMath for uint;

  function getLender(uint _marketId, address _lender) public view returns(uint, uint, uint, uint, uint) {
    uint actualOffer = actualLenderOffer(_lender, _marketId);
    return (
      getLenderOffer(_marketId, _lender), 
      actualOffer, 
      getLenderCollected(_marketId, _lender), 
      getLenderCollectible(_lender, _marketId),
      actualOffer.percent(_marketPool(_marketId), 5)
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

  function lender(uint _marketId, address _address) public view returns (bool) {
    if (actualLenderOffer(_address, _marketId) > 0) {
      return true;
    } else {
      return false;
    }
  }

  modifier isLender(uint _marketId, address _address) {
    require(lender(_marketId, _address));
    _;
  }

  modifier isNotLender(uint _marketId, address _address) {
    require (!lender(_marketId, _address));
    _;
  }

  function getLenderAddress(uint _marketId, uint _lenderId) public view returns (address) {
    return markets[_marketId].lenders[_lenderId];
  }

  function offerLoan(uint _marketId)
    public
    payable
    isRequestPeriod(_marketId)
    isNotLender(_marketId, msg.sender)
  {
    Market storage curMarket = markets[_marketId];
    curMarket.lenders.push(msg.sender);
    curMarket.lenderOffers[msg.sender] = msg.value;
    curMarket.totalLoaned = curMarket.totalLoaned.add(msg.value);
  }

  function calculateExcess(uint _marketId, address _address) public view returns (uint) {
    if (markets[_marketId].totalLoaned > markets[_marketId].totalRequested) {
      uint curValue = 0;
      for (uint i = 0; i < getLenderCount(_marketId); i++) {
        if (markets[_marketId].lenders[i] == _address) {
          if (curValue <= markets[_marketId].totalRequested) {
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
    return actualLenderOffer(_address, _marketId).mul(markets[_marketId].curRepaid).div(_marketPool(_marketId));
  }

  function collected(uint _marketId, address _address) public view returns (bool) {
    if (getLenderCollectible(_address, _marketId) == getLenderCollected(_marketId, _address) &&
      getLenderCollected(_marketId, _address) != 0) {
      return true;
    } else {
      return false;
    }
  }

  modifier hasCollected(uint _marketId, address _address) {
    require (collected(_marketId, _address));
    _;
  }

  modifier hasNotCollected(uint _marketId, address _address) {
    require (!collected(_marketId, _address));
    _;
  }

  function withdrawCollected(uint _marketId)
    public
    isCollectionPeriod(_marketId)
    isLender(_marketId, msg.sender)
    hasNotCollected(_marketId, msg.sender)
  {
    uint collectible = getLenderCollectible(msg.sender, _marketId);
    msg.sender.transfer(collectible);
    markets[_marketId].lenderCollected[msg.sender] = collectible;
  }
}