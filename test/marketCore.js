var MarketCore = artifacts.require("./MarketCore.sol");

const utils = require('./helpers/Utils');

contract('MarketCore', function(accounts) {

  beforeEach(async function () {
    this.marketCore = await MarketCore.deployed();
    this.createMarket = await this.marketCore.createMarket(1000, 1000, 1000, 5);
    this.marketId = this.createMarket.logs[0].args["marketId"].toNumber();
  })

  describe('getMarketCount', function() {
    describe('when one market has been created', function() {
      it('should return one', async function() {
        const count = await this.marketCore.getMarketCount();

        assert.equal(count.toNumber(), 1);
      })
    })
  })

  describe('marketPool', function() {
    it('should be zero wei when there is only lenders', async function() {
      await this.marketCore.offerLoan(this.marketId, {value: web3.toWei(10), from: accounts[0]});

      const value = await this.marketCore.marketPool(this.marketId);

      assert.equal(value.toNumber(), 0);
    })

    it('should be zero wei when there is only borrowers', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[1]});

      const value = await this.marketCore.marketPool(this.marketId);

      assert.equal(value.toNumber(), 0);
    })

    it('should be total lenders wei when there is more wei from borrowers', async function() {
      await this.marketCore.offerLoan(this.marketId, {value: web3.toWei(5), from: accounts[0]});
      await this.marketCore.requestLoan(this.marketId, web3.toWei(10), {from: accounts[1]});

      const value = await this.marketCore.marketPool(this.marketId);

      assert.equal(value.toNumber(), web3.toWei(5));
    })

    it('should be total borrower wei when there is more wei from lenders', async function() {
      await this.marketCore.offerLoan(this.marketId, {value: web3.toWei(10), from: accounts[0]});
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[1]});

      const value = await this.marketCore.marketPool(this.marketId);

      assert.equal(value.toNumber(), web3.toWei(5));
    })

    it('should be borrower and lender wei when borrower and lender wei is equal', async function() {
      await this.marketCore.offerLoan(this.marketId, {value: web3.toWei(5), from: accounts[0]});
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[1]});

      const value = await this.marketCore.marketPool(this.marketId);

      assert.equal(value.toNumber(), web3.toWei(5));
    })
  })
});
