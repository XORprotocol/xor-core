pragma solidity ^0.4.18;

import './MarketLend.sol';

contract MarketBorrow is MarketLend {

  function getBorrower(uint _marketId, address _borrower) public view returns(uint, uint ,uint ,uint ,uint) {
    uint actualRequest = actualBorrowerRequest(_marketId, _borrower);
    return (
      getBorrowerRequest(_marketId, _borrower),
      actualRequest,
      getBorrowerWithdrawn(_marketId, _borrower),
      getBorrowerRepaid(_marketId, _borrower),
      percent(actualRequest, marketPool(_marketId), 5)
    );
  }

  function getBorrowerIndex(uint _marketId, address _borrowerAddress) public view returns (uint) {
    uint index = 0;
    for (uint i = 0; i < markets[_marketId].borrowers.length; i++) {
      if (markets[_marketId].borrowers[i] == _borrowerAddress) {
        index = i;
      }
    }
    return index;
  }

  function getBorrowerCount(uint _marketId) public view returns (uint) {
    return markets[_marketId].borrowers.length;
  }

  function getBorrowerAddress(uint _marketId, uint _borrowerId) public view returns (address) {
    return markets[_marketId].borrowers[_borrowerId];
  }

  function getBorrowerRequest(uint _marketId, address _address) public view returns (uint) {
    return markets[_marketId].borrowerRequests[_address];
  }

  function getBorrowerWithdrawn(uint _marketId, address _borrower) public view returns (uint) {
    return markets[_marketId].borrowerWithdrawn[_borrower];
  }

  function getBorrowerRepaid(uint _marketId, address _borrower) public view returns (uint) {
    return markets[_marketId].borrowerRepaid[_borrower];
  }

  function isBorrower(uint _marketId, address _address) public view returns (bool) {
    if (markets[_marketId].borrowerRequests[_address] > 0) {
        return true;
    } else {
        return false;
    }
  }

  function requestLoan(uint _marketId, uint _amount) public {
    Market storage curMarket = markets[_marketId];
    require(curMarket.state == "request");
    // if (!checkRequestPeriod(_marketId)) {
    //   throw;
    // } else {
      curMarket.borrowers.push(msg.sender);
      curMarket.borrowerRequests[msg.sender] = _amount;
      curMarket.totalRequested = curMarket.totalRequested.add(_amount);
    // }
  }

  function repay(uint _marketId) public payable {
    Market storage curMarket = markets[_marketId];
    curMarket.curRepaid = curMarket.curRepaid.add(msg.value);
    curMarket.borrowerRepaid[msg.sender] = msg.value;
  }
}