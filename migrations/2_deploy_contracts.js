var MarketCore = artifacts.require("./MarketCore.sol");

var ExampleMarketTrust = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketTrust.sol");
var ExampleMarketInterest = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketInterest.sol");
var ExampleMarketAvatar = artifacts.require("./ExampleMarketAvatar.sol");
var ExampleMarketGovernance = artifacts.require("./ExampleMarketGovernance.sol");
var DOTFactory = artifacts.require("./DOTFactory.sol");

// var StringLib = artifacts.require("./StringLib.sol");
// var StringLib = artifacts.require("./StringUtils.sol");
var StringUtils = artifacts.require("./StringUtils.sol");

// var GenesisProtocol = artifacts.require("@daostack/arc/contracts/VotingMachines/GenesisProtocol.sol");

// var StandardToken = artifacts.require("openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol")

// var ExampleMarketGovernance2 = artifacts.require('./ExampleMarketGovernance2.sol');

module.exports = function(deployer) {
  deployer.deploy(MarketCore);
  // deployer.link(MarketCore, ExampleMarketTrust);
  // deployer.link(MarketCore, ExampleMarketInterest);
  // deployer.deploy(ExampleMarketTrust);
  // deployer.deploy(ExampleMarketInterest);
  deployer.deploy(StringUtils);
  deployer.link(StringUtils, DOTFactory);
  deployer.deploy(DOTFactory);
  deployer.deploy(ExampleMarketGovernance);
  // deployer.deploy(StandardToken)
  // .then(() => StandardToken.deployed())
  // .then(token => {
  // 	deployer.deploy(GenesisProtocol, token.address);
  // });
  // deployer.deploy(ExampleMarketGovernance2);
};
