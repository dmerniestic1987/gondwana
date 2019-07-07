const BigNumber = require('bignumber.js');
const assert = require('chai').assert;
const Web3 = require('web3');
var BetexSettings = artifacts.require("./BetexSettings.sol");
var BetexMobileGondwana = artifacts.require("./BetexMobileGondwana.sol");
var BetexCore = artifacts.require("./BetexCore.sol");
const web3 = new Web3(new Web3.providers.HttpProvider('https://rinkeby.infura.io/a973f72655dc4760bfc81012fec47c86'))

const PRECISION = 10 ** 18;
const defaultValues = {
    defaultMaxAmountWeiPerDay: web3.utils.toWei('100', 'ether'),
    defaultMaxAmountBtxPerDay: web3.utils.toBN(new BigNumber(10000 * PRECISION)),
    defaultMaxBetsPerDay: web3.utils.toBN(new BigNumber(1000)),
    minStakeWei: web3.utils.toWei('0.01', 'ether'),
    minStakeBtx: web3.utils.toBN(new BigNumber(1 * PRECISION)),
    maxStakeBtx: web3.utils.toBN(new BigNumber(10000 * PRECISION)),
    maxStakeWei: web3.utils.toWei('100', 'ether'),
    comissionWinnerBetWei: web3.utils.toBN(new BigNumber(0.05 * PRECISION)),
    comissionCancelBetWei: web3.utils.toBN(new BigNumber(0.02 * PRECISION)),
    comissionWinnerBetBtx: web3.utils.toBN(new BigNumber(0.05 * PRECISION)),
    comissionCancelBetBtx: web3.utils.toBN(new BigNumber(0.02 * PRECISION))
  }

contract('BetexSettings', async accounts => {
    let betexSettings;
    let betexMobileGondwana;
    let betexCore;
    const owner = accounts[0];
    const other = accounts[1];

    before(async() => {
        betexSettings = await BetexSettings.new();
        betexMobileGondwana = await BetexMobileGondwana.new();
        betexCore = await BetexCore.new();

        await betexSettings.init(betexMobileGondwana.address, betexCore.address,     
          defaultValues.defaultMaxAmountWeiPerDay, 
          defaultValues.defaultMaxAmountBtxPerDay,
          defaultValues.defaultMaxBetsPerDay,    
          defaultValues.minStakeWei,
          defaultValues.minStakeBtx,
          defaultValues.maxStakeBtx,
          defaultValues.maxStakeWei,
          defaultValues.comissionWinnerBetWei,
          defaultValues.comissionCancelBetWei,
          defaultValues.comissionWinnerBetBtx,
          defaultValues.comissionCancelBetBtx);
        
        await betexMobileGondwana.init(betexSettings);
    });

    describe('GIVEN un usuario que se autoexcluye', async () => {
        let tx;
    });
});