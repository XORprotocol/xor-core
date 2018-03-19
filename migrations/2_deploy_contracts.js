var Ownable = artifacts.require("./zeppelin/ownership/Ownable.sol");
var Killable = artifacts.require("./zeppelin/lifecycle/Killable.sol");
var SafeMath = artifacts.require("./libraries/SafeMath.sol");
var LoanMarket = artifacts.require("./LoanMarket.sol");

module.exports = function(deployer) {
  deployer.deploy(Ownable);
  deployer.link(Ownable, Killable);
  deployer.deploy(Killable);
  deployer.link(Killable, LoanMarket);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, LoanMarket);
  deployer.deploy(LoanMarket);
};
