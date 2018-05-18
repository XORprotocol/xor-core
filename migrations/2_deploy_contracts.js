var MarketCore = artifacts.require("./MarketCore.sol");

var ExampleMarketTrust = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketTrust.sol");
var ExampleMarketInterest = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketInterest.sol");
var ExampleMarketGovernance = artifacts.require("./ExampleMarketGovernance.sol");

// var StringLib = artifacts.require("./StringLib.sol");
var StringLib = artifacts.require("./StringUtils.sol");
var StringUtils = artifacts.require("./StringUtils.sol");

module.exports = function(deployer) {
  deployer.deploy(MarketCore);
  deployer.link(MarketCore, ExampleMarketTrust);
  deployer.link(MarketCore, ExampleMarketInterest);
  deployer.deploy(ExampleMarketTrust);
  deployer.deploy(ExampleMarketInterest);
  deployer.deploy(StringUtils);
  // deployer.link(StringLib, ExampleMarketGovernance);
  deployer.link(StringUtils, ExampleMarketGovernance);
  deployer.deploy(ExampleMarketGovernance);
};
