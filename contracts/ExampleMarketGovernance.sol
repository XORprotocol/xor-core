pragma solidity ^0.4.21;

import '@daostack/arc/contracts/VotingMachines/GenesisProtocol.sol';
import './StringLib.sol';


/**
  * @title MarketTrustInterface
  * @dev Interface for XOR Market Trust Contract for calculating trust score
 */

contract ExampleMarketGovernanceInterface {

  // Address from MarketCore
}


/**
  * @title ExampleMarketTrust
  * @dev Example Market Trust contract for showing trust score programmability.
 */

contract ExampleMarketGovernance is Destructible, GenesisProtocol {

  ExampleMarketGovernanceInterface exampleMarketGovernanceContract;

  GenesisProtocol genesisProtocolContract;

  DAOToken dotToken;

  ExecutableInterface executableInterfaceContract;

  Avatar avatar;

  /**
    * @dev Set the address of the sibling contract that tracks trust score.
   */
  function setMarketGovernanceContractAddress(address _address) external onlyOwner {
    exampleMarketGovernanceContract = ExampleMarketGovernanceInterface(_address);
  }

  /**
    * @dev Get the address of the sibling contract that tracks trust score.
   */
  function getMarketGovernanceContractAddress() external view returns(address) {
    return address(exampleMarketGovernanceContract);
  }


  function createGovernance(uint _marketId, address _tokenAddress) public {
    dotToken = DAOToken(_tokenAddress);

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

    bytes32 _newMarketId = StringUtils.uintToBytes(_marketId);

    avatar = new Avatar(_newMarketId, dotToken, reputation);

    // ControllerCreator controllerCreator;

    // controllerCreator.create(avatar);

    // DaoCreator daoCreator = new DaoCreator(controllerCreator.address);


  }

  function propose(uint _numOfChoices, ExecutableInterface _executable,address _proposer) public returns(bytes32) {
    genesisProtocolContract.propose(_numOfChoices, "", avatar, executableInterfaceContract, msg.sender);
  }

  // function execute(bytes32 _proposalId, address _avatar, int _param) public returns(bool) {

  // }

}