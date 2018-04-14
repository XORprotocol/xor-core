var Ownable = artifacts.require("./zeppelin/ownership/Ownable.sol");
var Killable = artifacts.require("./zeppelin/lifecycle/Killable.sol");
var SafeMath = artifacts.require("./libraries/SafeMath.sol");
var XorMath = artifacts.require("./libraries/XorMath.sol");
var MarketBase = artifacts.require("./MarketBase.sol");
var MarketIdentity = artifacts.require("./MarketIdentity.sol");
var MarketTime = artifacts.require("./MarketTime.sol");
var MarketInterest = artifacts.require("./MarketInterest.sol");
var MarketLend = artifacts.require("./MarketLend.sol");
var MarketBorrow = artifacts.require("./MarketBorrow.sol");
var MarketCore = artifacts.require("./MarketCore.sol");

var ExampleMarketTrust = artifacts.require("./examples/ExampleMarketTrust.sol");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.link(Ownable, Killable);
  deployer.deploy(Killable);
  deployer.link(Killable, MarketBase);
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
  deployer.link(Killable, ExampleMarketTrust);
  deployer.deploy(ExampleMarketTrust);
};
