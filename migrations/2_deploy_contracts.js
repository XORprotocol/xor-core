var MarketCore = artifacts.require("MarketCore");

var ExampleMarketTrust = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketTrust.sol");
var ExampleMarketInterest = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketInterest.sol");

module.exports = function(deployer) {
  deployer.deploy(MarketCore);
  deployer.link(MarketCore, ExampleMarketTrust);
  deployer.link(MarketCore, ExampleMarketInterest);
  deployer.deploy(ExampleMarketTrust);
  deployer.deploy(ExampleMarketInterest);
};
