var BetexCore = artifacts.require("./BetexCore.sol");

module.exports = function(deployer) {
  deployer.deploy(BetexCore);
};
