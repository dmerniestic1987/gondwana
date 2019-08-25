const BigNumber = require("bignumber.js");
const BetexSelfExcluded = artifacts.require("./BetexSelfExcluded.sol");
const BetexToken = artifacts.require("./BetexToken.sol");
const BetexSettings = artifacts.require("./BetexSettings.sol");
const BetexMobileGondwana = artifacts.require("./BetexMobileGondwana.sol");
const BetexCore = artifacts.require("./BetexCore.sol");
const BetexLaurasiaGondwana = artifacts.require("./BetexLaurasiaGondwana.sol");
const BetexStorage = artifacts.require("./BetexStorage.sol");
const config = {
  laurasiaAddress : "0x6e89F6fa95D517eE7a0a293D8A1d3C502bfB0701"

}
const MAX_MARKETS_PER_EVENT = 15;
const MAX_RUNNERS_PER_MARKET = 3;
module.exports = async function(deployer) {
  const PRECISION = 10 ** 18;
  const betexToken = await deployer.deploy(BetexToken);
  const betexSelfExcluded = await deployer.deploy(BetexSelfExcluded);
  const betexMobileGondwana = await deployer.deploy(BetexMobileGondwana);
  const betexCore = await deployer.deploy(BetexCore);
  const betexLaurasiaGondwana = await deployer.deploy(BetexLaurasiaGondwana);
  const betexStorage = await deployer.deploy(BetexStorage, MAX_RUNNERS_PER_MARKET, MAX_MARKETS_PER_EVENT);

  const defaultValues = {
    defaultMaxAmountWeiPerDay: web3.utils.toBN(
      web3.utils.toWei("100", "ether")
    ),
    defaultMaxAmountBtxPerDay: web3.utils.toBN(
      new BigNumber(10000 * PRECISION)
    ),
    defaultMaxBetsPerDay: web3.utils.toBN(new BigNumber(1000)),
    minStakeWei: web3.utils.toBN(web3.utils.toWei("0.01", "ether")),
    minStakeBtx: web3.utils.toBN(new BigNumber(1 * PRECISION)),
    maxStakeBtx: web3.utils.toBN(new BigNumber(10000 * PRECISION)),
    maxStakeWei: web3.utils.toBN(web3.utils.toWei("100", "ether")),
    comissionWinnerBetWei: web3.utils.toBN(new BigNumber(0.05 * PRECISION)),
    comissionCancelBetWei: web3.utils.toBN(new BigNumber(0.02 * PRECISION)),
    comissionWinnerBetBtx: web3.utils.toBN(new BigNumber(0.05 * PRECISION)),
    comissionCancelBetBtx: web3.utils.toBN(new BigNumber(0.02 * PRECISION))
  };

  const betexSettings = await deployer.deploy(BetexSettings);
  await betexSettings.init(
    betexMobileGondwana.address,
    betexCore.address,
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
    defaultValues.comissionCancelBetBtx
  );

  await betexMobileGondwana.init(
    betexSettings.address,
    betexSelfExcluded.address,
    betexCore.address
  );

  await betexCore.init(betexMobileGondwana.address, betexSettings.address, betexStorage.address);
  await betexStorage.init(betexCore.address, betexLaurasiaGondwana.address);
  await betexLaurasiaGondwana.init(betexStorage.address, config.laurasiaAddress);
};
