const Migrations = artifacts.require("Migrations");

module.exports = (deployer) => {
  deployer.deploy(Migrations, { gas: 4700000, gasPrice: 20});
};
