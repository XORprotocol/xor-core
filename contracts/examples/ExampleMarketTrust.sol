pragma solidity ^0.4.18;

import '../zeppelin/lifecycle/Killable.sol';
import '../libraries/SafeMath.sol';
import '../libraries/XorMath.sol';

/**
  * @title MarketTrustInterface
  * @dev Interface for XOR Market Trust Contract for calculating trust score
 */

contract MarketTrustInterface {

  // @dev given the address, returns the length of repayments array
  function getRepaymentsLength(address _address) public view returns (uint);

  // @dev given the address, returns the length of defaults array
  function getDefaultsLength(address _address) public view returns (uint);

  // @dev given the address, return the repayment at a specific index
  function getRepayment(address _address, uint _index) public view returns (uint);

  // @dev given the address, return the default at a specific index
  function getDefault(address _address, uint _index) public view returns (uint);
}


/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
 */

contract ExampleMarketTrust is Killable {
  using SafeMath for uint;
  using XorMath for uint;

  MarketTrustInterface marketTrustContract;

  /**
    * @dev Set the address of the sibling contract that track trust score.
   */
  function setMarketInterestContractAddress(address _address) external onlyOwner {
    marketTrustContract = MarketTrustInterface(_address);
  }

  /**
    * @dev Returns the trust score of a user by using repayments and defaults
   */
  function getTrustScore(address _address) public view returns (uint) {
    // uint[] repayments = marketTrustContract.getRepayments(_address);
    // uint[] defaults = marketTrustContract.getDefaults(_address);

    uint numRepayments = marketTrustContract.getRepaymentsLength(_address);
    uint numDefaults = marketTrustContract.getDefaultsLength(_address);

    // total value of all repayments in Wei
    uint totalRepayments;

    // total value of all defaults in Wei
    uint totalDefaults;

    // numerator of calculation
    uint repaymentComponent;

    // denominator of calculation
    uint defaultComponent;

    uint score;

    for (uint x = 0; x < numRepayments; x++) {
      totalRepayments = totalRepayments.add(marketTrustContract.getRepayment(_address, x));
    }
    for (uint y = 0; y < numDefaults; y++) {
      totalDefaults = totalDefaults.add(marketTrustContract.getDefault(_address, y));
    }

    repaymentComponent = totalRepayments.sqrt().div(100000000);

    // @note Calculation below gives defaults 1.25 weight relative to repayments of the same size
    defaultComponent = totalDefaults.sqrt().div(80000000);

    // Base trust score of 20, which is added to repaymentComponent and subtracted by defaultComponent
    score = repaymentComponent.add(20).sub(defaultComponent);
    // TODO: catch throw when score negative

    return score;
  }
}
