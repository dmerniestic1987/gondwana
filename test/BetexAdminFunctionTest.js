const BetexAdmin = artifacts.require("BetexAdmin");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

contract("BetexAdmin", async accounts => {
    let betexAdmin;
    const owner = accounts[0];
    const marketManager = accounts[1];
    const cfo = accounts[2];

    before(async() => {
        betexAdmin = await BetexAdmin.new();
        await betexAdmin.setMarketManager(marketManager, {from: owner});    
        await betexAdmin.setCFO(cfo, {from: owner});
    });
    
    var newMarketId;
    describe("GIVEN a un MarketManager seteado", async () => {
        let tx;
        beforeEach(async() => {    
            newMarketId = (await web3.eth.getBlock("latest")).number % 10 + 1;    
            tx = await betexAdmin.openMarket(newMarketId, { from: marketManager });
        });
        describe('AND el MarketManager abrió el mercado', async () => {
            it('THEN el mercado debe existir', async () => {
                const exists = await betexAdmin.marketExists(newMarketId);
                assert(exists, 'No existe el mercado');
            });
            it('El evento de nuevo mercado se debe disparar', async () => {            
                truffleAssert.eventEmitted(tx, 'OpenMarket', (ev) => {
                    return ev.marketId == newMarketId;
                });
            });
        });
    });
});