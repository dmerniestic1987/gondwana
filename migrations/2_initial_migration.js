var BetexCore = artifacts.require("./BetexCore.sol");
//var VersusMatches = artifacts.require("./VersusMatches.sol");
var BetexToken = artifacts.require("./BetexToken.sol");
//var BetexExchange = artifacts.require("./BetexExchange.sol");

module.exports = function(deployer) {
  deployContracts(deployer);
};

deployContracts = deployer => {
  deployer.deploy(BetexCore);
  deployer.deploy(BetexToken);
}
