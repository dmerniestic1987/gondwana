const BetexAuthorization = artifacts.require('BetexAuthorization');
const assert = require('chai').assert;
const truffleAssert = require('truffle-assertions');
const OWNABLE_MSG_ERROR = 'Ownable: caller is not the owner';
const OWNER_NOT_CTO_MSG_ERROR = 'Onwer must not be CTO';
const OWNER_NOT_MARKET_MANAGER_MSG_ERROR = 'Onwer must not be MarketManager';
contract('BetexAuthorization', async accounts => {
    let betexAuthorization;
    const owner = accounts[0];
    const marketManager = accounts[1];
    const cto = accounts[2];

    before(async() => {
        betexAuthorization = await BetexAuthorization.new();
    });

    describe('GIVEN a un MarketManager seteado', async () => {
        let tx;
        beforeEach(async() => {    
            tx = await betexAuthorization.setMarketManager(marketManager, {from: owner});    
        });
        it('THEN La nueva dirección del MarketManager debe ser igual', async () => {
            const settedMarketManager = await betexAuthorization.getMarketManager();
            assert(marketManager === settedMarketManager, 'MarketManagers diferentes');
        });
        it('THEN El evento de nuevo mercado se debe disparar', async () => {            
            truffleAssert.eventEmitted(tx, 'SettedMarketManager', (ev) => {
                return ev.newAddress == marketManager;
            });
        });
        describe('AND el onwer intenta setearse a sí mismo como marketManager', async() => {
            it('THEN setMarketManager debe fallar', async () => {
                marketManager
                await truffleAssert.reverts(
                     betexAuthorization.setMarketManager(owner, {from: owner}),
                     OWNER_NOT_MARKET_MANAGER_MSG_ERROR
                );
            });
        });
    });

    describe('GIVEN Un usuario CTO (indebido) trata de setear MarketManager ', async () => {
        it('THEN setMarketManager debe fallar', async () => {
            marketManager
            await truffleAssert.reverts(
                 betexAuthorization.setMarketManager(marketManager, {from: cto}),
                 OWNABLE_MSG_ERROR
            );
        });
    });

    describe('GIVEN a un CTO seteado', async () => {
        let tx;
        beforeEach(async() => {    
            tx = await betexAuthorization.setCTO(cto, {from: owner});    
        });
        it('THEN La nueva dirección del CT debe ser igual', async () => {
            const settedCTO = await betexAuthorization.getCTO();
            assert(cto === settedCTO, 'CTO diferentes');
        });
        it('THEN El evento de nuevo mercado se debe disparar', async () => {            
            truffleAssert.eventEmitted(tx, 'SettedCTO', (ev) => {
                return ev.newAddress == cto;
            });
        });
        describe('AND el onwer intenta setearse a sí mismo como CTO', async() => {
            it('THEN setCTO debe fallar', async () => {
                marketManager
                await truffleAssert.reverts(
                     betexAuthorization.setCTO(owner, {from: owner}),
                     OWNER_NOT_CTO_MSG_ERROR
                );
            });
        });
    });

    describe('GIVEN Un usuario MarketManager (indebido) trata de setear CTO ', async () => {
        it('THEN setMarketManager debe fallar', async () => {
            marketManager
            await truffleAssert.reverts(
                 betexAuthorization.setCTO(cto, {from: marketManager}),
                 OWNABLE_MSG_ERROR
            );
        });
    });
});