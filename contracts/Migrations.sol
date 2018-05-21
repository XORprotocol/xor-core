pragma solidity ^0.4.21; 

import 'xor-external-contract-examples/contracts/ExampleMarketTrust.sol';
import 'xor-external-contract-examples/contracts/ExampleMarketInterest.sol';
// import '@daostack/arc/contracts/VotingMachines/GenesisProtocol.sol';

contract Migrations {
    address public owner;

    // solhint-disable-next-line var-name-mixedcase
    uint public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function Migrations() public {
        owner = msg.sender;
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    function upgrade(address newAddress) public restricted {
        Migrations upgraded = Migrations(newAddress);
        upgraded.setCompleted(last_completed_migration);
    }
}
