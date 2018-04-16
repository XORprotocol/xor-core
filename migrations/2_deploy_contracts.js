var Ownable = artifacts.require("zeppelin-solidity/contracts/ownership/Ownable.sol");
var Destructible = artifacts.require("zeppelin-solidity/contracts/lifecycle/Destructible.sol");
var SafeMath = artifacts.require("zeppelin-solidity/contracts/math/SafeMath.sol");
var XorMath = artifacts.require("xor-libraries/contracts/XorMath.sol");
var MarketBase = artifacts.require("./MarketBase.sol");
var MarketIdentity = artifacts.require("./MarketIdentity.sol");
var MarketTime = artifacts.require("./MarketTime.sol");
var MarketInterest = artifacts.require("./MarketInterest.sol");
var MarketLend = artifacts.require("./MarketLend.sol");
var MarketBorrow = artifacts.require("./MarketBorrow.sol");
var MarketCore = artifacts.require("./MarketCore.sol");

var ExampleMarketTrust = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketTrust.sol");
var ExampleMarketInterest = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketInterest.sol");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.link(Ownable, Destructible);
  deployer.deploy(Destructible);
  deployer.link(Destructible, MarketBase);
  deployer.deploy(MarketBase);
  deployer.link(MarketBase, MarketIdentity);
  deployer.deploy(MarketIdentity);
  deployer.link(MarketIdentity, MarketTime);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, MarketTime);
  deployer.deploy(XorMath);
  deployer.link(XorMath, MarketTime);
  deployer.deploy(MarketTime);
  deployer.link(MarketTime, MarketInterest);
  deployer.link(SafeMath, MarketInterest);
  deployer.deploy(MarketInterest);
  deployer.link(MarketInterest, MarketLend);
  deployer.link(SafeMath, MarketLend);
  deployer.link(XorMath, MarketLend);
  deployer.deploy(MarketLend);
  deployer.link(MarketLend, MarketBorrow);
  deployer.link(SafeMath, MarketBorrow);
  deployer.link(XorMath, MarketBorrow);
  deployer.deploy(MarketBorrow);
  deployer.link(MarketBorrow, MarketCore);
  deployer.deploy(MarketCore);

  deployer.link(SafeMath, ExampleMarketTrust);
  deployer.link(XorMath, ExampleMarketTrust);
  deployer.link(Destructible, ExampleMarketTrust);
  deployer.deploy(ExampleMarketTrust);
};
