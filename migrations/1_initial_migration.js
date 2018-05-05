const Migrations = artifacts.require("Migrations");

module.exports = (deployer) => {
  deployer.deploy(Migrations);
  console.log(process.version);
};
