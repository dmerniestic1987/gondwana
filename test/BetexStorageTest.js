const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");
const BetexStorage = artifacts.require("./BetexStorage.sol");

const INCORRRECT_MARKET_STATUS = "Market status is incorrect";
const MARKET_STATUS_OPEN = web3.utils.toBN(0);
const MARKET_STATUS_READY = web3.utils.toBN(1);
const MARKET_STATUS_CLOSED = web3.utils.toBN(2);
const MARKET_STATUS_SUSPENDED = web3.utils.toBN(3);
const MAX_MARKETS_BY_EVENT = 10;
const MAX_RUNNERS_BY_MARKET = 3;
let tx;
let betexStorage;
const scenarios = [{
  description: 'Se crea un mercado con dos runners',
  eventId : 1,
  marketId : 22222,
  marketDescription: 'Ganador de pelea MMA',
  unrealMarketId: 91919191919191,
  runners: [web3.utils.sha3("Runner1"), web3.utils.sha3("Runner2")], 
  incorrectRunner : web3.utils.sha3("incorrecto")
},
{
  description: 'Se crea un mercado con tres runners',
  eventId : 5,
  marketId : 18,
  marketDescription: 'Más de 2.5 goles',
  unrealMarketId: 777777777,
  runners: [ web3.utils.sha3("Competidor1"), 
             web3.utils.sha3("Competidor2"), 
             web3.utils.sha3("Competidor3") ], 
  incorrectRunner : web3.utils.sha3("incorrecto")
}];
contract("BetexStorage", async accounts => {
  const owner = accounts[0];
  const betexCoreAddress = accounts[1];
  const betexLaurasiaAddress = accounts[2];
  before("Se crea un mercado y evento", async () => {
    betexStorage = await BetexStorage.new(MAX_RUNNERS_BY_MARKET, MAX_MARKETS_BY_EVENT, { from: owner });
    betexStorage.init(betexCoreAddress, betexLaurasiaAddress, { from: owner });
  });
  scenarios.forEach(s => {
    before(s.description, async () => {
      tx = await betexStorage.openMarket(s.eventId, s.marketId, s.runners.length, { from: betexLaurasiaAddress });
    });
    describe(`GIVEN se crea un nuevo mercado ${s.marketId}: ${s.marketDescription}`, async () => {
      it(`THEN el nuevo mercado debe existir`, async () => {
        const marketExist = await betexStorage.doesMarketExists(s.marketId);
        assert.isTrue(marketExist, "El mercado no existe");
      });
      describe("AND se agrega un nuevo runner", async () => {
        s.runners.forEach(runner => {
          it("THEN el nuevo runner debe existir", async () => {
            const txAddMarket = await betexStorage.addMarketRunner(
              s.marketId,
              runner,
              { from: betexLaurasiaAddress }
            );
            assert(txAddMarket != undefined, "No se ejecutó la transacción");
            const marketRunner = await betexStorage.getMarketRunners(s.marketId);
            assert(marketRunner != undefined, "No hay runners");
            assert(marketRunner.length > 0, "No hay runners");
          });
        });
      });
    });
    describe("WHEN se agregan todos los runners", async () => {
      it("THEN el mercado tiene que estar READY", async () => {
        const marketStatus = await betexStorage.getMarketStatus(s.marketId);
        assert(
          marketStatus.eq(MARKET_STATUS_READY),
          "El mercado no está READY"
        );
      });
      describe("AND se agrega otro runner", async () => {
        it("THEN deben revertear por tener más runners", async () => {
          await truffleAssert.reverts(
            betexStorage.addMarketRunner(
              s.marketId,
              s.incorrectRunner, 
              { from: betexLaurasiaAddress }
            ),
            INCORRRECT_MARKET_STATUS
          );
        });
      });
    });
    describe("GIVEN se consulta un mercado inexistente", async () => {
      it("THEN un mercado inexistente no debe existir", async () => {
        const marketExist = await betexStorage.doesMarketExists(s.unrealMarketId);
        assert.isFalse(marketExist, "El mercado no debería existir");
      });
    });
    describe("GIVEN el mercado se resuelve", async () => {
      before(s.description, async () => {
        tx = await betexStorage.resolverMarket(s.marketId, s.runners[1], { from: betexLaurasiaAddress });
      });
      it("THEN el mercado debe quedar en estado closed", async () => {
        const marketStatus = await betexStorage.getMarketStatus(s.marketId);
        assert(
          marketStatus.eq(MARKET_STATUS_CLOSED),
          "El mercado no está CLOSED"
        );
      });
      it(`AND el runner ${s.runners[0]} debe ser perdedor`, async () => {
        const isWinner = await betexStorage.isWinner(s.runners[0]);
        assert.isFalse(isWinner, "El runner no es looser");
      });
      it(`AND el runner ${s.runners[1]} debe ser ganador`, async () => {
        const isWinner = await betexStorage.isWinner(s.runners[1]);
        assert.isTrue(isWinner, "El runner no es winner");
      });
    });
  });

  describe("GIVEN se crea un nuevo mercado y luego se suspende", async () => {
    const EVENT_TO_SUSPEND = 199191;
    const MARKET_TO_SUSPEND = 1212;
    before(async () => {
      tx = await betexStorage.openMarket(EVENT_TO_SUSPEND, MARKET_TO_SUSPEND, 2, { from: betexLaurasiaAddress });
      const marketStatus = await betexStorage.getMarketStatus(MARKET_TO_SUSPEND);
      assert(
        marketStatus.eq(MARKET_STATUS_OPEN),
        "El mercado no está OPEN"
      );
    });
    it("THEN el mercado debe quedar en estado suspended", async () => {
      tx = await betexStorage.suspendMarket(MARKET_TO_SUSPEND, { from: betexLaurasiaAddress });
      const marketStatus = await betexStorage.getMarketStatus(MARKET_TO_SUSPEND);
      assert(
        marketStatus.eq(MARKET_STATUS_SUSPENDED),
        "El mercado no está SUSPENDED"
      );
    });
  });
});
