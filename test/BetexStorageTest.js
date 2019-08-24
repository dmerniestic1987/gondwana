const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");
const BetexStorage = artifacts.require("./BetexStorage.sol");

const RUNNER_ALREADY_EXIST = "Runner already exists";
const MARKET_STATUS_OPEN = web3.utils.toBN(0);
const MARKET_STATUS_READY = web3.utils.toBN(1);
const MARKET_STATUS_CLOSED = web3.utils.toBN(2);
const MARKET_STATUS_SUSPENDED = web3.utils.toBN(3);
let tx;
let betexStorage;
const eventId = 1;
const marketId = 22222;
const newMarketId = 4232;
const unrealMarketId = 91919191919191;
const runner1 = web3.utils.sha3("Runner1");
const runner2 = web3.utils.sha3("Runner2");
contract("BetexStorage", async accounts => {
  const owner = accounts[0];
  before("Se crea un mercado y evento", async () => {
    betexStorage = await BetexStorage.new(3, { from: owner });
    tx = await betexStorage.openMarket(eventId, marketId, 2);
  });
  describe("GIVEN se crea un nuevo mercado", async () => {
    it("THEN el nuevo mercado debe existir", async () => {
      const marketExist = await betexStorage.doesMarketExists(marketId);
      assert.isTrue(marketExist, "El mercado no existe");
    });
    describe("AND se agrega un nuevo runner", async () => {
      it("THEN el nuevo runner debe existir", async () => {
        const txAddMarket = await betexStorage.addMarketRunner(
          marketId,
          runner1
        );
        assert(txAddMarket != undefined, "No se ejecutó la transacción");
        const marketRunner = await betexStorage.getMarketRunners(marketId);
        assert(marketRunner != undefined, "No hay runners");
        assert(marketRunner.length == 1, "No hay runners");
        const marketStatus = await betexStorage.getMarketStatus(marketId);
        console.log(marketStatus.toString());
      });
      it("THEN el mercado debe estar en estado abierto", async () => {
        const marketStatus = await betexStorage.getMarketStatus(marketId);
        assert(marketStatus.eq(MARKET_STATUS_OPEN), "El mercado no está OPEN");
      });
    });
    describe("AND se agrega otro runner", async () => {
      it("THEN el nuevo runner debe existir", async () => {
        const txAddMarket = await betexStorage.addMarketRunner(
          marketId,
          runner2
        );
        assert(txAddMarket != undefined, "No se ejecutó la transacción");
        const marketRunner = await betexStorage.getMarketRunners(marketId);
        assert(marketRunner != undefined, "No hay runners");
        assert(marketRunner.length == 2, "No hay runners");
      });
      it("THEN el mercado tiene que estar READY", async () => {
        const marketStatus = await betexStorage.getMarketStatus(marketId);
        assert(
          marketStatus.eq(MARKET_STATUS_READY),
          "El mercado no está READY"
        );
      });
    });
  });
  describe("GIVEN se consulta un mercado inexistente", async () => {
    it("THEN un mercado inexistente no debe existir", async () => {
      const marketExist = await betexStorage.doesMarketExists(unrealMarketId);
      assert.isFalse(marketExist, "El mercado no debería existir");
    });
  });
});
