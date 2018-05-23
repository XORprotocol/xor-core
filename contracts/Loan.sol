import './ERC1068Basic.sol';
import './openzeppelin-solidity/contracts/token/ERC827/ERC827.sol'

contract Loan is ERC1068Basic {
	ERC827 dotContract;
	ERC827 tokenContract;

	function Loan(address _dotAddress, address tokenAddress) {
		dotContract = ERC827(_dotAddress);
		tokenContract = ERC827(_tokenAddress);
	}

	/// @notice funding the loan. (i.e. investors Rick send _capital Galactic Federation tokens to the contract,
  ///         the contract transfers principal raised to borrower Morty, contract records Rick's ownership prorated by the amount each contributed).
  /// @dev needs the token ERC20 functions to use _capital. This function will trigger Contribute event.
  /// @param _lender is the lender.
  /// @param _capital is the amount of token to contribute.
  function fund(address _lender, uint256 _capital) public returns (bool success);

  /// @notice retire capital from the loan. (i.e. borrower Morty has already paid back his due and investor Rick withdraw his loot).
  /// @dev Needs the token ERC20 functions to transfer _capital to msg.sender. This function will trigger Withdraw event.
  /// @to where the funds go.
  /// @param _capital is the amount of token to retire.
  function withdraw(address _to, uint256 _capital) public returns (bool success);

  /// @notice the borrower accept loan termns and collect the capital. (i.e. the principal raised at the moment is X tokens and
  ///         borrower Morty needs Y<X tokens, then Morty collect the principal raised and accept the loan terms).
  /// @dev change the loan stage to repayment.
  function accept() public returns (bool success);

  /// @notice pay back the due by borrower. (i.e. Morty send _payment Galactic Federation tokens to the contract,
  ///         the contract distributes the _paymen to loan investors prorated by the amount each contributed).
  /// @dev Needs the token ERC20 functions to transfer _payment. This function will trigger PayBack event.
  /// @param _who is who send the funds to payback.
  /// @param _payment is the amount of token to payback.
  function payback(address _from, uint256 _payment) public returns (bool success);

  /// @notice return the loan current stage. (i.e. Summer wants contribute in Morty loan, but first need see if the loan is in funding stage).
  /// @dev return loan current stage.
  /// @return current stage
  function stage() public view returns (uint8);
}
