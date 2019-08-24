const assert = require("chai").assert;
const truffleAssert = require("truffle-assertions");
const BetexStorage = artifacts.require("./BetexStorage.sol");

const RUNNER_ALREADY_EXIST = "Runner already exists";
const INCORRRECT_MARKET_STATUS = "Market status is incorrect";
const MARKET_STATUS_OPEN = web3.utils.toBN(0);
const MARKET_STATUS_READY = web3.utils.toBN(1);
const MARKET_STATUS_CLOSED = web3.utils.toBN(2);
const MARKET_STATUS_SUSPENDED = web3.utils.toBN(3);
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
  before("Se crea un mercado y evento", async () => {
    betexStorage = await BetexStorage.new(3, { from: owner });
  });
  scenarios.forEach(s => {
    before(s.description, async () => {
      tx = await betexStorage.openMarket(s.eventId, s.marketId, s.runners.length);
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
              runner
            );
            assert(txAddMarket != undefined, "No se ejecutó la transacción");
            const marketRunner = await betexStorage.getMarketRunners(s.marketId);
            assert(marketRunner != undefined, "No hay runners");
            assert(marketRunner.length > 0, "No hay runners");
            const marketStatus = await betexStorage.getMarketStatus(s.marketId);
            console.log(" * * MARKET STATUS: " + marketStatus.toString());
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
              s.incorrectRunner
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
  });
});
