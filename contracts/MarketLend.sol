pragma solidity ^0.4.23; 

import './MarketInterest.sol';

/**
  * @title MarketLend
  * @dev Contract containing business logic pertaining to lenders within a market
 */
 
contract MarketLend is MarketInterest {
  /*** EVENTS ***/
  /**
   * @dev Triggered when a new lender enters market and offers a loan
   * @param _address Address of lender
   */
  event LoanOffered(uint _marketId, address _address, uint _amount);
  
  /**
   * @dev Triggered when a lender who has a refundable excess amount transfers
   *      excess amount back to his address
   */
   event ExcessTransferred(uint _marketId, address _address, uint _amount);
   
   /**
    * @dev Triggered when a lender collects their collectible amount in collection
    *      period
    */
    event CollectibleCollected(uint _marketId, address _address, uint _amount);
    
  /*** GETTERS ***/    
  /**
   * @dev Fetches all relevant information about a lender in a particular Market.
   *      Utilizes various getter functions written below
   */
  function getLender(uint _marketId, address _lender) public view 
  returns(uint, uint, uint, uint, uint) {
    uint actualOffer = actualLenderOffer(_lender, _marketId);
    return (
      getLenderOffer(_marketId, _lender), 
      actualOffer, 
      getLenderCollected(_marketId, _lender), 
      getLenderCollectible(_lender, _marketId),
      actualOffer.percent(_marketPool(_marketId), 5)
    );
  }

  /**
   * @dev Retrieves the amount (in Wei) that a lender has offered/deposited into
   *      the market.
   *      Called before Request Period is complete.
   */
  function getLenderOffer(uint _marketId, address _address) public view returns (uint) {
    return markets[_marketId].lenderOffers[_address];
  }

  /**
   * @dev Calculates any excess lender funds that are not part of the market
   *      pool (when total amount offered > total amount requested)
   */
  function calculateExcess(uint _marketId, address _address) private view returns (uint) {
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
  
  /**
   * @dev Retrieves the "actual" size of loan offer corresponding to particular
   *      lender (after excess has been removed)
   * @notice This value would only differ from return value of getLenderOffer()
   *         for the same lender if total amount offered > total amount 
   *         requested and the lender is near the end of the queue
   * @notice This value should only differ from return value of getLenderOffer() for 
   *         ONE lender in a Market instance
   */ 
  function actualLenderOffer(address _address, uint _marketId) public view returns (uint) {
    return markets[_marketId].lenderOffers[_address].sub(calculateExcess(_marketId, _address));
  }
  
  /**
   * @dev Retrieves the amount (in Wei) that a lender has collected back from
   *      their loan/investment
   */
  function getLenderCollected(uint _marketId, address _address) public view returns (uint) {
    return markets[_marketId].lenderCollected[_address];
  }

  /**
   * @dev Retrieves the collectible amount for each lender from their investment/
   *      loan. Includes principal + interest - defaults.
   */
  function getLenderCollectible(address _address, uint _marketId) public view returns (uint) {
    return actualLenderOffer(_address, _marketId).mul(markets[_marketId].curRepaid).div(_marketPool(_marketId));
  }

  /**
   * @dev Fetches the index of a lender within array of lenders in Market 
   *      (from their address)
   * NOTE: This function currently not used anywhere
   */
  function getLenderIndex(uint _marketId, address _address) public view returns (uint) {
    uint index = 0;
    for (uint i = 0; i < getLenderCount(_marketId); i++) {
      if (markets[_marketId].lenders[i] == _address) {
        index = i;
      }
    }
    return index;
  }

  /**
   * @dev Fetches the number of registered lenders in a certain market
   */
  function getLenderCount(uint _marketId) public view returns (uint) {
    return markets[_marketId].lenders.length;
  }

  /**
   * @dev Retrieves address of a lender from their lenderID in market
   */
  function getLenderAddress(uint _marketId, uint _lenderId) public view returns (address) {
    return markets[_marketId].lenders[_lenderId];
  }
  
  /**
   * @dev Returns true if given individual is a lender (after request period concludes 
   *      and excess lenders are removed), false otherwise
   */
  function lender(uint _marketId, address _address) public view returns (bool) {
    if ((checkRequestPeriod(_marketId) && getLenderOffer(_marketId, _address) > 0) ||
      actualLenderOffer(_address, _marketId) > 0) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Returns true if given lender has collected their collectible
   *      amount
   */
  function collected(uint _marketId, address _address) public view returns (bool) {
    if (getLenderCollectible(_address, _marketId) == getLenderCollected(_marketId, _address) &&
      getLenderCollected(_marketId, _address) != 0) {
      return true;
    } else {
      return false;
    }
  }

  /*** SETTERS & TRANSACTIONS ***/
  /**
   * @dev Offers a loan, and locks funds into the Market contract. Caller
   *      then becomes a lender in the current market.
   * @notice Even when a lender offers a loan with this function, at the end of
   *         the request period, they may not necessarily remain a lender (and
   *         thus have their funds returned) if total amount offered > total amount 
   *         requested
   */ 
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
    LoanOffered(_marketId, msg.sender, msg.value);
  }

  /**
   * @dev Called by lenders who have been removed. Transfers excess amount exceeding
   *      market pool back to them.
   * TODO: try catch for when person calling is not lender
   */
  function transferExcess(uint _marketId) public 
  isLender(_marketId, msg.sender)
  isAfterRequestPeriod(_marketId) {
    require(markets[_marketId].lenderOffers[msg.sender] > 0);
    uint excessAmt = calculateExcess(_marketId, msg.sender);
    msg.sender.transfer(excessAmt);
    ExcessTransferred(_marketId, msg.sender, excessAmt);
  }

  /**
   * @dev Transfers collectible amount (interest + principal - defaults) to respective 
   *      lender
   */
  function collectCollectible(uint _marketId) public 
  isCollectionPeriod(_marketId) isLender(_marketId, msg.sender)
  hasNotCollected(_marketId, msg.sender) {
    uint collectibleAmt = getLenderCollectible(msg.sender, _marketId);
    markets[_marketId].lenderCollected[msg.sender] = collectibleAmt;
    msg.sender.transfer(collectibleAmt);
    CollectibleCollected(_marketId, msg.sender, collectibleAmt);
  }
  
  /*** MODIFIERS ***/
  /**
   * @dev Throws if individual being checked is not a lender in market
   */
  modifier isLender(uint _marketId, address _address) {
    require(lender(_marketId, _address));
    _;
  }
  
  /**
   * @dev Throws if individual being checked is a lender in market
   */
  modifier isNotLender(uint _marketId, address _address) {
    require (!lender(_marketId, _address));
    _;
  }
  
  /**
   * @dev Throws if lender being checked has not collected their collectible amount
   */
  modifier hasCollected(uint _marketId, address _address) {
    require (collected(_marketId, _address));
    _;
  }

  /**
   * @dev Throws if lender being checked has collected their collectible amount
   */
  modifier hasNotCollected(uint _marketId, address _address) {
    require (!collected(_marketId, _address));
    _;
  }
}