import './ERC1068Basic.sol';
import './openzeppelin-solidity/contracts/token/ERC827/ERC827.sol'

contract LoanGovernanceInterface {
  function createGovernance();
  function getGenesisProtocolContractAddress() external view returns(address);
}

contract LoanBase is ERC1068Basic {
	ERC827 dotContract;
	ERC827 tokenContract;

  // Time in Linux Epoch Time of Version creation
  uint updatedAt; 

  // Duration of "Request Period" during which borrowers submit loan requests 
  // and lenders offer loans
  uint requestPeriod;
  
  // Duration of "Loan Period" during which the loan is actually taken out
  uint loanPeriod;
  
  // Duration of "Settlement Period" during which borrowers repay lenders
  uint settlementPeriod; 
  
  // @notice Reason "Collection Period" is not a field is because it is infinite
  //         by default. Lenders have an unlimited time period within which
  //         they can collect repayments and interest 

  // Size of lending pool put forward by lenders in market (in Wei)
  uint totalOffered; 

  // Value of total amount requested by borrowers in market (in Wei)
  uint totalRequested; 
  
  // Amount taken out by borrowers on loan at a given time (in Wei)
  uint curBorrowed; 
  
  // Amount repaid by borrowers at a given time (in Wei)
  uint curRepaid;

  // Address of external governance contract
  // address governanceContractAddress;
  LoanGovernanceInterface governanceContract;

  // Address of external trust contract
  address trustContractAddress;

  // Address of external interest contract
  address interestContractAddress;

  // Array of all lenders participating in the market
  address[] lenders; 
  
  // Array of all borrowers participating in the market
  address[] borrowers; 

  // Mapping of each lender (their address) to the size of their loan offer
  // (in Wei); amount put forward by each lender
  mapping (address => uint) lenderOffers; 
  
  // Mapping of each borrower (their address) to the size of their loan request
  // (in Wei)
  mapping (address => uint) borrowerRequests;
  
  // Mapping of each borrower to amount they have withdrawn from their loan (in Wei)
  mapping (address => uint) borrowerWithdrawn; 
  
  // Mapping of each borrower to amount of loan they have repaid (in Wei)
  mapping (address => uint) borrowerRepaid;

  // Mapping of each lender to amount that they have collected back from loans (in Wei)
  // NOTE: Currently, lenders must collect their entire collectible amount
  //       at once. In future, there are plans to allow lenders to only collect part of 
  //       collectible amount at any one time
  mapping (address => uint) lenderCollected; 

    /** 
   * @param _periodArray 
            [request, loan, settlement]
   * @param _contractAddressesArray An array containing the addresses of instance
   *                               component contracts
   *                               [governance, trust, interest, dotAddress, tokenAddress]
   */
	function LoanBase(uint[] _periodArray, address[] _contractAddressesArray) public {
    requestPeriod = _periodArray[0];
    loanPeriod = _periodArray[1];
    settlementPeriod = _periodArray[2];
    governanceContract = LoanGovernanceInterface(_contractAddressesArray[0]);
    trustContractAddress = _contractAddressesArray[1];
    interestContractAddress = _contractAddressesArray[2];
		dotContract = ERC827(_contractAddressesArray[3]);
		tokenContract = ERC827(_contractAddressesArray[4]);
	}
}
