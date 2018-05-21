pragma solidity ^0.4.21;

import '@daostack/arc/contracts/controller/Avatar.sol';

contract ExampleMarketAvatar {
	Avatar avatar;

  function createAvatar(bytes32 _strMarketId, DAOToken daoToken, Reputation reputation) public returns(address) {
  	avatar = new Avatar(_strMarketId, daoToken, reputation);
  	return address(avatar);
  }
}