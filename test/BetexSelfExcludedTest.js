const BetexSelfExcluded = artifacts.require('BetexSelfExcluded');
const assert = require('chai').assert;

contract('BetexSelfExcluded', async accounts => {
    let betexSelfExcluded;
    const owner = accounts[0];
    const user = accounts[1];

    before(async() => {
        betexSelfExcluded = await BetexSelfExcluded.new();
    });

    describe('GIVEN un usuario que se autoexcluye', async () => {
        let tx;
        beforeEach(async() => {    
            tx = await betexSelfExcluded.selfExclude({from: user});    
        });
        it('THEN el usuario figurar como selfExcluded', async () => {
            const isExcluded = await betexSelfExcluded.isSelfExcluded(user);
            assert.isTrue(isExcluded, 'User no excluído');
        });
        it('THEN el owner figurar como selfExcluded', async () => {
            const isExcluded = await betexSelfExcluded.isSelfExcluded(owner);
            assert.isTrue(isExcluded, 'Owner no excluído');
        });
    });
});