const Web3 = require('web3');
var BetexSelfExcluded = artifacts.require("./BetexSelfExcluded.sol");
var BetexToken = artifacts.require("./BetexToken.sol");
var BetexSettings = artifacts.require("./BetexSettings.sol");
var BetexMobileGondwana = artifacts.require("./BetexMobileGondwana.sol");
var BetexCore = artifacts.require("./BetexCore.sol");
const web3 = new Web3(new Web3.providers.HttpProvider('https://rinkeby.infura.io/a973f72655dc4760bfc81012fec47c86'))

module.exports = async function(deployer) {
  const PRECISION = 10 ** 18;
  console.log(deployer);
  const betexToken = await deployer.deploy(BetexToken);
  console.log(betexToken);
  const betexSelfExcluded = await deployer.deploy(BetexSelfExcluded);
  console.log(betexSelfExcluded);
  const betexMobileGondwana = await deployer.deploy(BetexMobileGondwana);
  console.log(betexMobileGondwana);
  const betexCore = await deployer.deploy(BetexCore);
  console.log(betexCore);
  
  const defaultValues = {
    defaultMaxAmountWeiPerDay: web3.utils.toWei('100', 'ether'),
    defaultMaxAmountBtxPerDay: 10000 * PRECISION,
    defaultMaxBetsPerDay: 1000,
    minStakeWei: web3.utils.toWei('0.01', 'ether'),
    minStakeBtx: 1 * PRECISION,
    maxStakeBtx: 10000 * PRECISION,
    maxStakeWei: web3.utils.toWei('100', 'ether'),
    comissionWinnerBetWei: 0.05 * PRECISION,
    comissionCancelBetWei: 0.02 * PRECISION,
    comissionWinnerBetBtx: 0.05 * PRECISION,
    comissionCancelBetBtx: 0.02 * PRECISION    
  }

  const betexSettings = await deployer.deploy(BetexSettings);
  betexSettings.init(betexMobileGondwana, betexCore,     
    defaultValues.defaultMaxAmountWeiPerDay.toString(), 
    defaultValues.defaultMaxAmountBtxPerDay.toString(),
    defaultValues.defaultMaxBetsPerDay.toString(),    
    defaultValues.minStakeWei.toString(),
    defaultValues.minStakeBtx.toString(),
    defaultValues.maxStakeBtx.toString(),
    defaultValues.maxStakeWei.toString(),
    defaultValues.comissionWinnerBetWei.toString(),
    defaultValues.comissionCancelBetWei.toString(),
    defaultValues.comissionWinnerBetBtx.toString(),
    defaultValues.comissionCancelBetBtx.toString());
 console.log(betexSettings);

};