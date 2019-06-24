const BetexAuthorization = artifacts.require("BetexAuthorization");
const assert = require("chai").assert;
const truffleAssert = require('truffle-assertions');

contract("BetexAuthorization", async accounts => {
    let betexAuthorization;
    const owner = accounts[0];
    const marketManager = accounts[1];
    const cto = accounts[2];

    before(async() => {
        betexAuthorization = await BetexAuthorization.new();
        await betexAuthorization.setMarketManager(marketManager, {from: owner});    
        await betexAuthorization.setCTO(cto, {from: owner});
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