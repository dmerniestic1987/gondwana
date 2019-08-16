const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");
const BetexStorage = artifacts.require("./BetexStorage.sol");
const Web3 = require("web3");
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

const marketDate = new Date();
const eventDate = new Date();
const eventIdTimer = eventDate.getTime() + 444;
const marketIdTimer = marketDate.getTime() + 154;
const testValues = {
  event01: {
    eventId: web3.utils.toBN(eventIdTimer),
    markets: [
      {
        marketId: web3.utils.toBN(marketIdTimer),
        description: "OK Market 01",
        runners: [
          web3.utils.keccak256("RUNNER0001"),
          web3.utils.keccak256("RUNNER0002")
        ]
      },
      {
        marketId: web3.utils.toBN(marketIdTimer + 1),
        description: "OK Market 02",
        runners: [
          web3.utils.keccak256("Competidor 01"),
          web3.utils.keccak256("Competidor 02")
        ]
      },
      {
        marketId: web3.utils.toBN(marketIdTimer + 2),
        description: "OK Market 03",
        runners: [
          web3.utils.keccak256("RUNNER0003"),
          web3.utils.keccak256("RUNNER0002"),
          web3.utils.keccak256("RUNNER0003")
        ]
      },
      {
        marketId: web3.utils.toBN(-3),
        description: "Market Error -03",
        runners: [
          web3.utils.keccak256("1-e4 c5"),
          web3.utils.keccak256("2-Cf3 e6")
        ]
      }
    ]
  }
};

contract("BetexStorage", async accounts => {
  const owner = accounts[0];
  const betexStorage = await BetexStorage.new(web3.utils.toBN(3));
  describe("GIVEN se crea un nuevo mercado", async () => {
    let tx;
    before("Se crea un nuevo evento", async () => {
      console.log(testValues.event01.eventId, testValues.event01.markets[0].marketId, testValues.event01.markets[0].runners);
      tx = await betexStorage.openMarket(
        testValues.event01.eventId,
        testValues.event01.markets[0].marketId,
        web3.eth.abi.encodeParameter('bytes32[]', ["0x7880aec93413f117ef14bd4e6d130875ab2c7d7d55a064fac3c2f7bd51516380", "0x7880aec93413f117ef14bd4e6d130875ab2c7d7d55a064fac3c2f7bd51516380"])
      );
    });
    it('THEN El evento de nuevo mercado se debe disparar', async () => {            
      truffleAssert.eventEmitted(tx, 'Test', (ev) => {
          return ev.key == 'openMarket';
      });
    });
    describe(`THEN el mercado ${
      testValues.event01.markets[0].marketId
    } debe tener runners.`, async () => {
      it(`THEN el mercado ${
        testValues.event01.markets[0].marketId
      } debe existir.`, async () => {
        const marketExists = await betexStorage.doesMarketExists(
          testValues.event01.markets[0].marketId
        );
        assert(marketExists, "El mercado no existe");
      });

      it("AND runners deben ser los mismos", async () => {
        console.log(testValues);
        const market00Runners = await betexStorage.getMarketRunners(
          testValues.event01.markets[0].marketId
        );
        assert.equal(
          market00Runners,
          testValues.event01.markets[0].runners,
          "No iguales"
        );
      });
    });
  });
});
