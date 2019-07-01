var BetexSelfExcluded = artifacts.require("./BetexSelfExcluded.sol");
var BetexToken = artifacts.require("./BetexToken.sol");
var BetexSettings = artifacts.require("./BetexSettings.sol");
var BetexMobileGondwana = artifacts.require("./BetexMobileGondwana.sol");
var BetexCore = artifacts.require("./BetexCore.sol");

module.exports = async function(deployer) {
  console.log(deployer);
  const betexToken = await deployer.deploy(BetexToken);
  console.log(betexToken);
  const betexSelfExcluded = await deployer.deploy(BetexSelfExcluded);
  console.log(betexSelfExcluded);
  const betexMobileGondwana = await deployer.deploy(BetexMobileGondwana);
  console.log(betexMobileGondwana);
  const betexCore = await deployer.deploy(BetexCore);
  console.log(betexCore);

  const betexSettings = await deployer.deploy(BetexSettings);
  betexSettings.init(betexMobileGondwana, betexCore);
  console.log(betexSettings);

};