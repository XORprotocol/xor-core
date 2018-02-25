var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var LoanMarket = artifacts.require("./LoanMarket.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(LoanMarket);
};
