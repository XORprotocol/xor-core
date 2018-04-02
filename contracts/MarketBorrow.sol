pragma solidity ^0.4.18;

import './MarketLend.sol';
import './libraries/SafeMath.sol';
import './libraries/XorMath.sol';

contract MarketBorrow is MarketLend {
  using XorMath for uint;
  using SafeMath for uint;

  event LoanRequested(uint _marketId, address _address, uint _amount);

  function getBorrower(uint _marketId, address _borrower) public view returns(uint, uint ,uint ,uint ,uint) {
    uint actualRequest = actualBorrowerRequest(_marketId, _borrower);
    return (
      getBorrowerRequest(_marketId, _borrower),
      actualRequest,
      getBorrowerWithdrawn(_marketId, _borrower),
      getBorrowerRepaid(_marketId, _borrower),
      actualRequest.percent(_marketPool(_marketId), 5)
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

  function borrower(uint _marketId, address _address) public view returns (bool) {
    if ((checkRequestPeriod(_marketId) && getBorrowerRequest(_marketId, _address) > 0) || 
      actualBorrowerRequest(_marketId, _address) > 0) {
      return true;
    } else {
      return false;
    }
  }

  modifier isBorrower(uint _marketId, address _address) {
    require(borrower(_marketId, _address));
    _;
  }

  modifier isNotBorrower(uint _marketId, address _address) {
    require (!borrower(_marketId, _address));
    _;
  }

  function repaid(uint _marketId, address _address) public view returns (bool) {
    Market storage curMarket = markets[_marketId];
    uint actualRequest = actualBorrowerRequest(_marketId, _address);
    uint expectedRepayment = actualRequest.add(getInterest(_address, actualRequest, _marketId));
    if (curMarket.borrowerRepaid[msg.sender] == expectedRepayment) {
      return true;
    } else {
      return false;
    }
  }

  modifier hasRepaid(uint _marketId, address _address) {
    require(repaid(_marketId, _address));
    _;
  }

  modifier hasNotRepaid(uint _marketId, address _address) {
    require(!repaid(_marketId, _address));
    _;
  }

  function requestLoan(uint _marketId, uint _amount)
    public
    isRequestPeriod(_marketId)
    isNotBorrower(_marketId, msg.sender)
    isNotLender(_marketId, msg.sender)
  {
    Market storage curMarket = markets[_marketId];
    curMarket.borrowers.push(msg.sender);
    curMarket.borrowerRequests[msg.sender] = _amount;
    curMarket.totalRequested = curMarket.totalRequested.add(_amount);
    LoanRequested(_marketId, msg.sender, _amount);
  }

  function repay(uint _marketId)
    public
    payable
    isSettlementPeriod(_marketId)
    isBorrower(_marketId, msg.sender)
    hasNotRepaid(_marketId, msg.sender)
  {
    Market storage curMarket = markets[_marketId];
    curMarket.curRepaid = curMarket.curRepaid.add(msg.value);
    curMarket.borrowerRepaid[msg.sender] = msg.value;
  }

  function getRepayment(address _address, uint _marketId) public view returns (uint) {
    uint request = actualBorrowerRequest(_marketId, _address);
    return request.add(getInterest(_address, request, _marketId));
  }

  function actualBorrowerRequest(uint _marketId, address _address) public view returns(uint) {
    Market storage curMarket = markets[_marketId];
    if (curMarket.totalLoaned >= curMarket.totalRequested) {
      return curMarket.borrowerRequests[_address];
    } else {
      uint curValue = 0;
      uint requestValue = 0;
      for(uint i = 0; i < getBorrowerCount(_marketId); i++) {
        if (curMarket.borrowers[i] == _address) {
          if (curValue < curMarket.totalLoaned) {
            uint newValue = curValue.add(curMarket.borrowerRequests[_address]);
            if (newValue > curMarket.totalLoaned) {
              uint diff = newValue.sub(curMarket.totalLoaned);
              requestValue = curMarket.borrowerRequests[_address].sub(diff);
            } else {
              requestValue =  curMarket.borrowerRequests[_address];
            }
          }
          break;
        }
        curValue = curValue.add(curMarket.borrowerRequests[curMarket.borrowers[i]]);
      }
      return requestValue;
    }
  }

  function withdrawn(uint _marketId, address _address) public view returns(bool) {
    if (getBorrowerRequest(_marketId, _address) == getBorrowerWithdrawn(_marketId, _address)
      && getBorrowerWithdrawn(_marketId, _address) > 0) {
      return true;
    } else {
      return false;
    }
  }

  modifier hasWithdrawn(uint _marketId, address _address) {
    require(withdrawn(_marketId, _address));
    _;
  }

  modifier hasNotWithdrawn(uint _marketId, address _address) {
    require(!withdrawn(_marketId, _address));
    _;
  }

  function withdrawRequested(uint _marketId)
    public
    isLoanPeriod(_marketId)
    isBorrower(_marketId, msg.sender)
    hasNotWithdrawn(_marketId, msg.sender)
  {
    uint request = actualBorrowerRequest(_marketId, msg.sender);
    msg.sender.transfer(request);
    markets[_marketId].borrowerWithdrawn[msg.sender] = request;
    markets[_marketId].curBorrowed = markets[_marketId].curBorrowed.add(request);
  }
}