pragma solidity ^0.4.18; 

import './SafeMath.sol';

/**
 * @title XorMath
 * @dev Math operations specific to XOR protocol
 */

library XorMath {
  using SafeMath for uint256;

  /** 
  @dev Returns quotient (numerator/denominator) in percentage form to a certain degree of precision
  Ex: numerator: 101,450, denominator: 3, precision: 3, result: 224, i.e. 22.4%
  @param precision the number of digits to display
   https://ethereum.stackexchange.com/questions/18870/is-there-a-good-way-to-calculate-a-ratio-in-solidity-since-there-is-no-float-do
   */
  function percent(uint256 numerator, uint256 denominator, uint256 precision)
  internal pure returns(uint256 quotient) {
    // caution, check safe-to-multiply here
    uint256 _numerator  = numerator * 10 ** (precision+1);
    // with rounding of last digit
    uint256 _quotient =  (( _numerator.div(denominator)) + 5) / 10;
    return ( _quotient);
  }

  /**
  @dev Returns square root of x
  https://ethereum.stackexchange.com/questions/2910/can-i-square-root-in-solidity
  */
  function sqrt(uint x) internal pure returns (uint y) {
    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
        y = z;
        z = (x / z + z) / 2;
    }
  }
}
