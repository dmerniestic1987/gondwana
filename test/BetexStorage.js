const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");
const BetexStorage = artifacts.require("./BetexStorage.sol");
const Web3 = require("web3");
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

const marketDate = new Date();
const eventDate = new Date();
const eventId = eventDate.getTime();
const marketId = marketDate.getTime() + 154;
const testValues = {
  event01: {
    eventId: web3.utils.toBN(eventId),
    markets: [
      {
        id: web3.utils.toBN(marketId),
        description: "OK Market 01",
        runners: [
          web3.utils.fromAscii("RUNNER0001"),
          web3.utils.fromAscii("RUNNER0002"),
          web3.utils.fromAscii("RUNNER0003")
        ]
      },
      {
        id: web3.utils.toBN(marketId + 1),
        description: "OK Market 02",
        runners: [
          web3.utils.fromAscii("Competidor 01"),
          web3.utils.fromAscii("Competidor 02")
        ]
      },
      {
        id: web3.utils.toBN(marketId + 2),
        description: "OK Market 03",
        runners: [
          web3.utils.fromAscii("RUNNER0003"),
          web3.utils.fromAscii("RUNNER0002"),
          web3.utils.fromAscii("RUNNER0003")
        ]
      },
      {
        id: web3.utils.toBN(-3),
        description: "Market Error -03",
        runners: [
          web3.utils.fromAscii("1-e4 c5"),
          web3.utils.fromAscii("2-Cf3 e6")
        ]
      }
    ]
  }
};
let tx;
contract("BetexStorage", async accounts => {
  const owner = accounts[0];
  const betexStorage = await BetexStorage.new(web3.utils.toBN(3));

  describe("GIVEN se crea un nuevo mercado", async () => {
    describe("Se crea un nuevo evento", async () => {
      tx = await betexStorage.openMarket(
        testValues.event01.eventId,
        testValues.event01.markets[0].id,
        testValues.event01.markets[0].runners
      );
    });
    describe(`THEN el mercado ${
      testValues.event01.markets[0].description
    } debe existir.`, async () => {
      it("AND runners deben ser los mismos", async () => {
        console.log(testValues.toString());
        const market00Runners = await betexStorage.getMarketRunners(
          testValues.event01.markets[0].id
        );
        assert.equal(
          market00Runners,
          testValues.event01.markets[0].runners,
          "No iguales"
        );
      });
      it("AND market deben existir", async () => {
        const marketExists = await betexStorage.doesMarketExists(
          testValues.event01.markets[0].id
        );
        assert(marketExists, "El mercado no existe");
      });
    });
  });
});
