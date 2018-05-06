var MarketCore = artifacts.require("./MarketCore.sol");
var ExampleMarketTrust = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketTrust.sol");
var ExampleMarketInterest = artifacts.require("xor-external-contract-examples/contracts/ExampleMarketInterest.sol");

const utils = require('./helpers/Utils.js')

contract('MarketBorrow', function(accounts) {

  beforeEach(async function () {
    this.exampleMarketTrust = await ExampleMarketTrust.deployed();
    this.exampleMarketInterest = await ExampleMarketInterest.deployed();
    this.exampleContractAddresses = ["0x0000", this.exampleMarketTrust.address, 
    this.exampleMarketInterest.address];
    this.marketCore = await MarketCore.deployed();
    this.createMarket = await this.marketCore.createMarket(
      1000,
      1000,
      1000,
      5,
      this.exampleContractAddresses
    );
    this.createMarket2 = await this.marketCore.createMarket(
      1000,
      1000,
      1000,
      5,
      this.exampleContractAddresses
    );
    this.marketId = this.createMarket.logs[0].args["marketId"].toNumber();
    this.marketId2 = this.createMarket2.logs[0].args["marketId"].toNumber();
  });

  describe('requestLoan', function() {
    it('should succeed if called in request period', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});

      const borrowerCount = await this.marketCore.getBorrowerCount(this.marketId);

      assert.equal(borrowerCount.toNumber(), 1);
    })

    it('should fail if called twice', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      try {
        await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      } catch (error) {
        return utils.ensureException(error);
      }
      assert.fail('Expected exception not received');
    })

    it('should fail if called in loan period', async function() {
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [1001], id: 0});
      try {
        await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      } catch (error) {
        return utils.ensureException(error);
      }
      assert.fail('Expected exception not received');
    })

    it('should fail if already lender', async function() {
      await this.marketCore.offerLoan(this.marketId, {value: web3.toWei(10)});
      const lender = await this.marketCore.lender(this.marketId, accounts[0]);
      try {
        await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      } catch (error) {
        return utils.ensureException(error);
      }
      assert.fail('Expected exception not received');
    })
  })

  describe('borrower', function() {
    it('should return true if request period and borrower request greater than zero', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      await this.marketCore.offerLoan(this.marketId, {value: web3.toWei(10), from: accounts[1]});
      const borrower = await this.marketCore.borrower(this.marketId, accounts[0]);
      const requestPeriod = await this.marketCore.checkRequestPeriod(this.marketId, {from: accounts[0]});
      const getMarketPeriod = await this.marketCore.getMarketPeriod(this.marketId);
      assert.equal(requestPeriod, true);
      assert.equal(borrower, true);
    })

    it('should return true if actual borrower request is greater than zero', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      await this.marketCore.offerLoan(this.marketId, {value: web3.toWei(10), from: accounts[1]});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [1001], id: 0});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
      const actualBorrowerRequest = await this.marketCore.actualBorrowerRequest(this.marketId, accounts[0]);
      const borrower = await this.marketCore.borrower.call(this.marketId, accounts[0]);
      // const loanPeriod = await this.marketCore.checkLoanPeriod(this.marketId);
      assert.equal(actualBorrowerRequest, web3.toWei(5));
      // assert.equal(loanPeriod, true);
      assert.equal(borrower, true);
    })

    it('should return false if borrower request is zero', async function() {
      const borrower = await this.marketCore.borrower(this.marketId, accounts[0]);
      assert.equal(borrower, false);
    })

    it('should return false if actual borrower request is zero after request period', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [1001], id: 0});
      web3.currentProvider.send({jsonrpc: "2.0", method: "evm_mine", params: [], id: 0})
      const borrower = await this.marketCore.borrower(this.marketId, accounts[0]);
      assert.equal(borrower, false);
    })
  })

  describe('getBorrowerRequest', function() {
    it('should return correct request amount', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      const getBorrowerRequest = await this.marketCore.getBorrowerRequest(this.marketId, accounts[0]);
      assert.equal(web3.toWei(5), getBorrowerRequest);
    })
  })

  describe('actualBorrowerRequest', function() {
    it('should return zero if no lenders', async function() {
      await this.marketCore.requestLoan(this.marketId, web3.toWei(5), {from: accounts[0]});
      const getLenderCount = await this.marketCore.getLenderCount(this.marketId);
      const actualBorrowerRequest = await this.marketCore.actualBorrowerRequest(this.marketId, accounts[0]);
      assert.equal(0, getLenderCount);
      assert.equal(0, actualBorrowerRequest);
    })
  })
});
