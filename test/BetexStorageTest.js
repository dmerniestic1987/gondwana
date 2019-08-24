const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");
const BetexStorage = artifacts.require("./BetexStorage.sol");

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
    tx = await betexStorage.openMarket(eventId, marketId);
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
      });
    });
    describe("AND se agrega otro runner", async () => {
      it("THEN un mercado inexistente debe existir", async () => {
        const txAddMarket = await betexStorage.addMarketRunner(
          marketId,
          runner2
        );
        assert(txAddMarket != undefined, "No se ejecutó la transacción");
        const marketRunner = await betexStorage.getMarketRunners(marketId);
        assert(marketRunner != undefined, "No hay runners");
        assert(marketRunner.length == 2, "No hay runners");
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
