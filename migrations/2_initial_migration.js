var BetexSelfExcluded = artifacts.require("./BetexSelfExcluded.sol");
var BetexToken = artifacts.require("./BetexToken.sol");
var BetexSettings = artifacts.require("./BetexSettings.sol");

module.exports = async function(deployer) {
  console.log(deployer);
  const betexSettings = await deployer.deploy(BetexSettings);
  console.log(betexSettings);
  const betexToken = await deployer.deploy(BetexToken);
  console.log(betexToken);
  const betexSelfExcluded = await deployer.deploy(BetexSelfExcluded);
  console.log(betexSelfExcluded);
};