pragma solidity ^0.4.21; 

import './MarketLend.sol';

/**
  * @title MarketBorrow
  * @dev Contract containing business logic pertaining to borrowers within a market
 */
 
contract MarketBorrow is MarketLend {
  /*** EVENTS ***/
  /**
   * @dev Triggered when a borrower enters market and requests a loan
   */
  event LoanRequested(uint _marketId, address _address, uint _amount);

  /**
   * @dev Triggered when a borrower has repaid his loan
   */
  event LoanRepaid(uint _marketId, address _address, uint _amount);
  
  /*** GETTERS ***/
  /**
   * @dev Fetches all relevant information about a borrower in a particular Market.
   *      Utilizes various getter functions written below
   */
  function getBorrower(uint _marketId, address _borrower) 
    public 
    view 
    returns(uint, uint ,uint ,uint ,uint) 
  {
    uint actualRequest = actualBorrowerRequest(_marketId, _borrower);
    return (
      getBorrowerRequest(_marketId, _borrower),
      actualRequest,
      getBorrowerWithdrawn(_marketId, _borrower),
      getBorrowerRepaid(_marketId, _borrower),
      actualRequest.percent(getMarketPool(_marketId), 5)
    );
  }
  
  /**
   * @dev Retrieves the "actual" size of loan request corresponding to particular
   *      borrower (after excess has been removed)
   * @notice This value would only differ from return value of getBorrowerRequest()
   *         for the same borrower if total amount requested > total amount 
   *         offered and the borrower is near the end of the queue
   * @notice This value should only differ from return value of getBorrowerRequest() for 
   *         ONE borrower in a Market instance
   */ 
  function actualBorrowerRequest(uint _marketId, address _address) 
    public
    view
    returns(uint) 
  {
    uint totalOffered = getMarketTotalOffered(_marketId);
    uint totalRequested = getMarketTotalRequested(_marketId);
    uint borrowerRequest = getBorrowerRequest(_marketId, _address);
    if (totalOffered >= totalRequested) {
      return getBorrowerRequest(_marketId, _address);
    } else {
      uint curValue = 0;
      uint requestValue = 0;
      for(uint i = 0; i < getBorrowerCount(_marketId); i++) {
        if (getBorrowerAddress(_marketId,i) == _address) {
          if (curValue < totalOffered) {
            uint newValue = curValue.add(borrowerRequest);
            if (newValue > totalOffered) {
              uint diff = newValue.sub(totalOffered);
              requestValue = borrowerRequest.sub(diff);
            } else {
              requestValue = borrowerRequest;
            }
          }
          break;
        }
        curValue = curValue.add(getBorrowerRequest(_marketId, getBorrowerAddress(_marketId,i)));
      }
      return requestValue;
    }
  }
  
  /**
   * @dev Fetches the total size of repayment a borrower has to make to cover
   *      principal + interest
   */
  function getTotalRepayment(uint _marketId, address _address) public view returns (uint) {
    uint request = actualBorrowerRequest(_marketId, _address);
    return request.add(getInterest(_address, request));
  }
  
  /**
   * @dev Fetches the index of a borrower within array of borrowers in Market 
   *      (from their address)
   * NOTE: This function currently not used anywhere
   */
  function getBorrowerIndex(uint _marketId, address _borrowerAddress) public view returns (uint) {
    uint index = 0;
    for (uint i = 0; i < getBorrowerCount(_marketId); i++) {
      if (getBorrowerAddress(_marketId,i) == _borrowerAddress) {
        index = i;
      }
    }
    return index;
  }

  /**
   * @dev Fetches the number of registered borrowers in a certain market
   */
  function getBorrowerCount(uint _marketId) public view returns (uint) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    return markets[_marketId].versions[curVersionNum].borrowers.length;
  }

  /**
   * @dev Retrieves address of a borrower from their borrowerID in market
   */
  function getBorrowerAddress(uint _marketId, uint _borrowerId) public view returns (address) {
    uint curVersionNum = getCurVersionNumber(_marketId);
    return markets[_marketId].versions[curVersionNum].borrowers[_borrowerId];
  }

  /**
   * @dev Returns true if given individual is a borrower (after request period concludes 
   *      and excess borrowers are removed), false otherwise
   */
  function borrower(uint _marketId, address _address) public view returns (bool) {
    if ((checkRequestPeriod(_marketId) && getBorrowerRequest(_marketId, _address) > 0) || 
      actualBorrowerRequest(_marketId, _address) > 0) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @dev Returns true if given borrower has withdrawn the entire amount of their
   *      loan request, false otherwise
   */
  function withdrawn(uint _marketId, address _address) public view returns (bool) {
    if (getBorrowerRequest(_marketId, _address) == getBorrowerWithdrawn(_marketId, _address)
      && getBorrowerWithdrawn(_marketId, _address) > 0) {
      return true;
    } else {
      return false;
    }
  }
  
  /**
   * @dev Returns true if a borrower has repaid his loan in the market, false
   * otherwise
   */
  function repaid(uint _marketId, address _address) public view returns (bool) {
    uint actualRequest = actualBorrowerRequest(_marketId, _address);
    uint expectedRepayment = actualRequest.add(getInterest(_address, actualRequest));
    if (getBorrowerRepaid(_marketId, msg.sender) == expectedRepayment) {
      return true;
    } else {
      return false;
    }
  }
  
  /*** SETTERS & TRANSACTIONS ***/
  /**
   * @dev Submits a Loan Request in the Market. Caller then becomes a borrower in
   *      the current Market.
   * @notice Even when a borrower submits a request with this function, at the end of
   *         the request period, they may not necessarily remain a borrower (and
   *         (and thus not receive their loan) if total amount requested > total amount 
   *         offered
   */ 
  function requestLoan(uint _marketId, uint _amount)
    external
    isRequestPeriod(_marketId)
    isNotBorrower(_marketId, msg.sender)
    isNotLender(_marketId, msg.sender)
  {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    curMarketVer.borrowers.push(msg.sender);
    curMarketVer.borrowerRequests[msg.sender] = _amount;
    curMarketVer.totalRequested = curMarketVer.totalRequested.add(_amount);
    emit LoanRequested(_marketId, msg.sender, _amount);
  }

  /**
   * @dev Withdraws requested amount to borrower's address from lending pool
   */
  function withdrawRequested(uint _marketId)
    external
    isLoanPeriod(_marketId)
    isBorrower(_marketId, msg.sender)
    hasNotWithdrawn(_marketId, msg.sender)
  {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    uint request = actualBorrowerRequest(_marketId, msg.sender);
    msg.sender.transfer(request);
    curMarketVer.borrowerWithdrawn[msg.sender] = request;
    curMarketVer.curBorrowed = curMarketVer.curBorrowed.add(request);
  }
  
  /**
   * @dev Repays principal and interest back to "repayment pool" to be distributed
   *      to lenders
   * @notice Partial repayments not supported at this time.
   */
  function repay(uint _marketId)
    external
    payable
    isSettlementPeriod(_marketId)
    isBorrower(_marketId, msg.sender)
    hasNotRepaid(_marketId, msg.sender)
  {
    uint curVersionNum = getCurVersionNumber(_marketId);
    Version storage curMarketVer = markets[_marketId].versions[curVersionNum];
    curMarketVer.curRepaid = curMarketVer.curRepaid.add(msg.value);
    curMarketVer.borrowerRepaid[msg.sender] = msg.value;
    addToRepayments(msg.sender, msg.value);
    emit LoanRepaid(_marketId, msg.sender, msg.value);
  }

  /*** MODIFIERS ***/
  /**
   * @dev Throws if individual being checked is not a borrower in market
   */
  modifier isBorrower(uint _marketId, address _address) {
    require(borrower(_marketId, _address));
    _;
  }

  /**
   * @dev Throws if individual being checked is a borrower in market
   */
  modifier isNotBorrower(uint _marketId, address _address) {
    require (!borrower(_marketId, _address));
    _;
  }
  
  /**
   * @dev Throws if borrower being checked has not repaid their loan principal/interest
   */
  modifier hasRepaid(uint _marketId, address _address) {
    require(repaid(_marketId, _address));
    _;
  }
  
  /**
   * @dev Throws if borrower being checked has repaid their loan principal/interest
   */
  modifier hasNotRepaid(uint _marketId, address _address) {
    require(!repaid(_marketId, _address));
    _;
  }
  
  /**
   * @dev Throws if borrower being checked has not withdrawn the full amount
   *      of their loan request
   */
  modifier hasWithdrawn(uint _marketId, address _address) {
    require(withdrawn(_marketId, _address));
    _;
  }

  /**
   * @dev Throws if borrower being checked has withdrawn the full amount
   *      of their loan request
   */
  modifier hasNotWithdrawn(uint _marketId, address _address) {
    require(!withdrawn(_marketId, _address));
    _;
  }
}