const BigNumber = require('bignumber.js');
const assert = require('chai').assert;
const truffleAssert = require('truffle-assertions');
const Web3 = require('web3');
var BetexSettings = artifacts.require("./BetexSettings.sol");
var BetexMobileGondwana = artifacts.require("./BetexMobileGondwana.sol");
var BetexSelfExcluded = artifacts.require('BetexSelfExcluded.sol');
var BetexCore = artifacts.require("./BetexCore.sol");
const web3 = new Web3(new Web3.providers.HttpProvider('https://rinkeby.infura.io/a973f72655dc4760bfc81012fec47c86'))

const PRECISION = 10 ** 18;
const NOT_ALLOWED_MSG_ERROR = 'Not allowed';
const defaultValues = {
    defaultMaxAmountWeiPerDay: web3.utils.toBN(web3.utils.toWei('100', 'ether')),
    defaultMaxAmountBtxPerDay: web3.utils.toBN(new BigNumber(10000 * PRECISION)),
    defaultMaxBetsPerDay: web3.utils.toBN(new BigNumber(1000)),
    minStakeWei: web3.utils.toBN(web3.utils.toWei('0.01', 'ether')),
    minStakeBtx: web3.utils.toBN(new BigNumber(1 * PRECISION)),
    maxStakeBtx: web3.utils.toBN(new BigNumber(10000 * PRECISION)),
    maxStakeWei: web3.utils.toBN(web3.utils.toWei('100', 'ether')),
    comissionWinnerBetWei: web3.utils.toBN(new BigNumber(0.05 * PRECISION)),
    comissionCancelBetWei: web3.utils.toBN(new BigNumber(0.02 * PRECISION)),
    comissionWinnerBetBtx: web3.utils.toBN(new BigNumber(0.05 * PRECISION)),
    comissionCancelBetBtx: web3.utils.toBN(new BigNumber(0.02 * PRECISION))
  }

contract('BetexSettings', async accounts => {
    let betexSettings;
    let betexMobileGondwana;
    let betexCore;
    let betexSelfExcluded;
    const owner = accounts[0];
    const other = accounts[1];

    before(async() => {
        betexSettings = await BetexSettings.new();
        betexMobileGondwana = await BetexMobileGondwana.new();
        betexCore = await BetexCore.new();
        betexSelfExcluded = await BetexSelfExcluded.new();
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
        
        await betexMobileGondwana.init(betexSettings.address, betexSelfExcluded.address);
    });

    describe('GIVEN un usuario desea configurar betex con Gondwana', async () => {
        describe('AND consulta los valores por default', async () => {
            let defaultSettings;
            beforeEach(async() => {
                defaultSettings = await betexMobileGondwana.getUserSettings();
            });
            it('THEN maxAmountWeiPerDay del usuario deben ser los mismos que por default', async () => {
                assert(defaultSettings[0].eq(defaultValues.defaultMaxAmountWeiPerDay),"maxAmountWeiPerDay diferente a default");
            });
            it('THEN maxAmountBtxPerDay del usuario deben ser los mismos que por default', async () => {
                assert(defaultSettings[1].eq(defaultValues.defaultMaxAmountBtxPerDay), "maxAmountBtxPerDay diferente a default");
            });
            it('THEN maxAmountWeiPerDay del usuario deben ser los mismos que por default', async () => {
                assert(defaultSettings[2].eq(defaultValues.defaultMaxBetsPerDay), "maxBetsPerDay diferente a default");
            });
        });
        describe('AND configura nuevos valores', async () => {
            let settings;
            const maxAmoutWei = web3.utils.toBN(web3.utils.toWei('50', 'ether'));
            const maxAmountBtx = web3.utils.toBN(600 * PRECISION);
            const maxCantApuestas = web3.utils.toBN(10 * PRECISION);
            beforeEach(async() => {
                await betexMobileGondwana.saveUserSettings(maxAmoutWei,maxAmountBtx, maxCantApuestas);
                settings = await betexMobileGondwana.getUserSettings();
            });
            it('THEN maxAmountWeiPerDay del usuario deben ser los mismos que a los de configuración', async () => {
                assert(settings[0].eq(maxAmoutWei),"maxAmountWeiPerDay diferente a configurado");
            });
            it('THEN maxAmountBtxPerDay del usuario deben ser los mismos que  a los de configuración', async () => {
                assert(settings[1].eq(maxAmountBtx), "maxAmountBtxPerDay diferente a configurado");
            });
            it('THEN maxAmountWeiPerDay del usuario deben ser los mismos que   a los de configuración', async () => {
                assert(settings[2].eq(maxCantApuestas), "maxBetsPerDay diferente a configurado");
            });
        });
    });
    describe('GIVEN un address que no está en la white list', async () => {
        describe('AND intenta configurar y setear parámetros sin permisos', async () => {
            it('THEN la transacción debe revertear al llamar a getMinStakeWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.getMinStakeWei({from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
            it('THEN la transacción debe revertear al llamar a setMinStakeWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.setMinStakeWei(1000, {from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
            it('THEN la transacción debe revertear al llamar a getMaxStakeWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.getMaxStakeWei({from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
            it('THEN la transacción debe revertear al llamar a setMaxStakeWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.setMaxStakeWei(1000, {from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
            it('THEN la transacción debe revertear al llamar a getComissionWinnerBetWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.getComissionWinnerBetWei({from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
            it('THEN la transacción debe revertear al llamar a setComissionWinnerBetWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.setComissionWinnerBetWei(1000, {from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
            it('THEN la transacción debe revertear al llamar a getComissionCancelBetWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.getComissionCancelBetWei({from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
            it('THEN la transacción debe revertear al llamar a setComissionCancelBetWei', async () => {
                await truffleAssert.reverts(
                    betexSettings.setComissionCancelBetWei(1000, {from: owner}),
                    NOT_ALLOWED_MSG_ERROR
                );
            });
        });
    });
});