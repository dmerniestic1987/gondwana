var BetexCore = artifacts.require("./BetexCore.sol");

module.exports = function(deployer) {
  deployer.deploy(BetexCore);
  console.log('Esto lo estoy haciendo volaaaar');
};
