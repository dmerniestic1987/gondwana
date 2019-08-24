const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");
const BetexStorage = artifacts.require("./BetexStorage.sol");

let tx;
let betexStorage;
const eventId = 22222;
const marketId = 22222;
const unrealMarketId = 91919191919191;
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
  });
  describe("GIVEN se consulta un mercado inexistente", async () => {
    it("THEN un mercado inexistente no debe existir", async () => {
      const marketExist = await betexStorage.doesMarketExists(unrealMarketId);
      assert.isFalse(marketExist, "El mercado no debería existir");
    });
  });
});
