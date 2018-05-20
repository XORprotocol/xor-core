pragma solidity ^0.4.21;

// import './DOTFactory.sol';
// import './Strings.sol';
// import './StringUtils.sol';
import '@daostack/arc/contracts/VotingMachines/GenesisProtocol.sol';

/**
  * @title MarketTrustInterface
  * @dev Interface for XOR Market Trust Contract for calculating trust score
 */

contract ExampleMarketGovernanceInterface {

  // Address from MarketCore
  function getDOTTokenAddress(uint _marketId) public returns(address);
}

contract ExampleMarketAvatarInterface {

  function createAvatar(bytes32 _strMarketId, DAOToken daoToken, Reputation reputation) public returns(address);
}


/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
  */
contract ExampleMarketGovernance  {
  ExampleMarketGovernanceInterface exampleMarketGovernanceContract;
  ExampleMarketAvatarInterface exampleMarketAvatarContract;
  GenesisProtocol genesisProtocolContract;
  ExecutableInterface executableInterfaceContract;
  // Avatar avatar;
  address avatarAddress;


  /**
    * @dev Set the address of the sibling contract that tracks trust score.
   */
  function setMarketGovernanceContractAddress(address _address) external {
    exampleMarketGovernanceContract = ExampleMarketGovernanceInterface(_address);
  }

  /**
    * @dev Get the address of the sibling contract that tracks trust score.
   */
  function getMarketGovernanceContractAddress() external view returns(address) {
    return address(exampleMarketGovernanceContract);
  }


  /**
    * @dev Set the address of the sibling contract that tracks trust score.
   */
  function setMarketAvatarContractAddress(address _address) external {
    exampleMarketAvatarContract = ExampleMarketAvatarInterface(_address);
  }

  /**
    * @dev Get the address of the sibling contract that tracks trust score.
   */
  function getMarketAvatarContractAddress() external view returns(address) {
    return address(exampleMarketAvatarContract);
  }


  function createGovernance(uint _marketId, bytes32 _strMarketId) public {
    StandardToken dotToken = StandardToken(exampleMarketGovernanceContract.getDOTTokenAddress(_marketId));

    genesisProtocolContract = new GenesisProtocol(dotToken);

    uint[12] memory params;
    params[0] = 50;
    params[1] = 60;
    params[2] = 60;
    params[3] = 1;
    params[4] = 1;
    params[5] = 0;
    params[6] = 0;
    params[7] = 60;
    params[8] = 1;
    params[9] = 1;
    params[10] = 10;
    params[11] = 80;

    genesisProtocolContract.setParameters(params);

    executableInterfaceContract = ExecutableInterface(address(this));

    Reputation reputation = new Reputation();

    DAOToken daoToken = DAOToken(exampleMarketGovernanceContract.getDOTTokenAddress(_marketId));

    avatarAddress = exampleMarketAvatarContract.createAvatar(_strMarketId, daoToken, reputation);

    // avatar = new Avatar(_strMarketId, daoToken, reputation);





  //   // ControllerCreator controllerCreator;

  //   // controllerCreator.create(avatar);

  //   // DaoCreator daoCreator = new DaoCreator(controllerCreator.address);
  }

  function propose(uint _numOfChoices, address _proposer) public returns(bytes32) {
    // genesisProtocolContract.propose(_numOfChoices, "", avatar, executableInterfaceContract, msg.sender);
  }

  // function execute(bytes32 _proposalId, address _avatar, int _param) public returns(bool) {

  // }
}

