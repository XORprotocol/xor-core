pragma solidity ^0.4.21;

import './DOTFactory.sol';
import './Strings.sol';
import './StringUtils.sol';

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

contract ExampleMarketGovernance is Destructible, DOTFactory {
  using strings for *;

  ExampleMarketGovernanceInterface exampleMarketGovernanceContract;
  address DOTTokenAddress;
  GenesisProtocol genesisProtocolContract;
  ExecutableInterface executableInterfaceContract;
  Avatar avatar;


  function uint2str(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
  }

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

  function createDOTUsingMarketId(uint _marketId) public {
    string memory strId = uint2str(_marketId);
    var name = "Debt Obligation Token ".toSlice().concat(strId.toSlice());
    var symbol = "DOT".toSlice().concat(strId.toSlice());
    DOTTokenAddress = createDOT(name, symbol, 0);
  }

  function getDOTTokenAddress() public view returns(address) {
    return DOTTokenAddress;
  }

  function createGovernance(uint _marketId) public {
    StandardToken dotToken = StandardToken(DOTTokenAddress);

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

    DAOToken daoToken = DAOToken(DOTTokenAddress);

    avatar = new Avatar(_newMarketId, daoToken, reputation);

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

