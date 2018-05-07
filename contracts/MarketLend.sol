pragma solidity ^0.4.21; 

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
    uint actualOffer = actualLenderOffer(_marketId,_lender);
    return (
      getLenderOffer(_marketId, _lender), 
      actualOffer, 
      getLenderCollected(_marketId, _lender), 
      getLenderCollectible(_lender, _marketId),
      actualOffer.percent(getMarketPool(_marketId), 5)
    );
  }

  /**
   * @dev Calculates any excess lender funds that are not part of the market
   *      pool (when total amount offered > total amount requested)
   */
  function calculateExcess(uint _marketId, address _address) private view returns (uint) {
    uint totalOffered = getMarketTotalOffered(_marketId);
    uint totalRequested = getMarketTotalRequested(_marketId);
    uint lenderOffer = getLenderOffer(_marketId, _address);
    if (totalOffered > totalRequested) {
      uint curValue = 0;
      for (uint i = 0; i < getLenderCount(_marketId); i++) {
        if (getMarketLenders(_marketId)[i] == _address) {
          if (curValue <= totalRequested) {
            uint newValue = curValue.add(lenderOffer);
            if (newValue > totalRequested) {
              uint diff = totalRequested.sub(curValue);
              return lenderOffer.sub(diff);
            } else {
              return 0;
            }
          }
          break;
        }
        curValue = curValue.add(getLenderOffer(_marketId,getMarketLenders(_marketId)[i]));
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
  function actualLenderOffer(uint _marketId, address _address) public view returns (uint) {
    return getLenderOffer(_marketId,_address).sub(calculateExcess(_marketId, _address));
  }

  /**
   * @dev Retrieves the collectible amount for each lender from their investment/
   *      loan. Includes principal + interest - defaults.
   */
  function getLenderCollectible(address _address, uint _marketId) public view returns (uint) {
    return actualLenderOffer(_marketId, _address).mul(getMarketCurRepaid(_marketId)).div(getMarketPool(_marketId));
  }

  function getLenderCount(uint _marketId) public view returns (uint) {
    return getMarketLenders(_marketId).length;
  }

  /**
   * @dev Retrieves address of a lender from their lenderID in market
   */
  function getLenderAddress(uint _marketId, uint _lenderId) public view returns (address) {
    return getMarketLenders(_marketId)[_lenderId];
  }
  
  /**
   * @dev Returns true if given individual is a lender (after request period concludes 
   *      and excess lenders are removed), false otherwise
   */
  function lender(uint _marketId, address _address) public view returns (bool) {
    if ((checkRequestPeriod(_marketId) && getLenderOffer(_marketId, _address) > 0) ||
      actualLenderOffer(_marketId, _address) > 0) {
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
    external
    payable
    isRequestPeriod(_marketId)
    isNotLender(_marketId, msg.sender)
  {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    curMarketVer.lenders.push(msg.sender);
    curMarketVer.lenderOffers[msg.sender] = msg.value;
    curMarketVer.totalOffered = curMarketVer.totalOffered.add(msg.value);
    emit LoanOffered(_marketId, msg.sender, msg.value);
  }

  /**
   * @dev Called by lenders who have been removed. Transfers excess amount exceeding
   *      market pool back to them.
   * TODO: try catch for when person calling is not lender
   */
  function transferExcess(uint _marketId) 
    external 
    isLender(_marketId, msg.sender)
    isAfterRequestPeriod(_marketId) 
  {
    require(getLenderOffer(_marketId, msg.sender) > 0);
    uint excessAmt = calculateExcess(_marketId, msg.sender);
    msg.sender.transfer(excessAmt);
    emit ExcessTransferred(_marketId, msg.sender, excessAmt);
  }

  /**
   * @dev Transfers collectible amount (interest + principal - defaults) to respective 
   *      lender
   */
  function collectCollectible(uint _marketId) 
    external
    isCollectionPeriod(_marketId) isLender(_marketId, msg.sender)
    hasNotCollected(_marketId, msg.sender) 
  {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    uint collectibleAmt = getLenderCollectible(msg.sender, _marketId);
    curMarketVer.lenderCollected[msg.sender] = collectibleAmt;
    msg.sender.transfer(collectibleAmt);
    emit CollectibleCollected(_marketId, msg.sender, collectibleAmt);
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