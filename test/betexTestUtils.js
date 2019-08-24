const Web3 = require("web3");
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
const { BN } = web3.utils;

module.exports = async () => {
  return {
    web3,
    BN
  };
};
