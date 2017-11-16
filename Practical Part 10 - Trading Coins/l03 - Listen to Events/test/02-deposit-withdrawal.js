var fixedSupplyToken = artifacts.require("./FixedSupplyToken.sol");
var exchange = artifacts.require("./Exchange.sol");

contract('Exchange Basic Tests', function (accounts) {
    it("should be possible to add tokens", function () {
        var myTokenInstance;
        var myExchangeInstance;
        return fixedSupplyToken.deployed().then(function (instance) {
            myTokenInstance = instance;
            return exchange.deployed();
        }).then(function (exchangeInstance) {
            myExchangeInstance = exchangeInstance;
            return myExchangeInstance.addToken("FIXED", myTokenInstance.address);
        }).then(function (txResult) {
            assert.equal(txResult.logs[0].event, "TokenAddedToSystem", "TokenAddedtoSystem Event should be emitted");
            return myExchangeInstance.hasToken.call("FIXED");
        }).then(function (booleanHasToken) {
            assert.equal(booleanHasToken, true, "The Token was not added");
            return myExchangeInstance.hasToken.call("SOMETHING");
        }).then(function (booleanHasNotToken) {
            assert.equal(booleanHasNotToken, false, "A Token that doesn't exist was found.");
        });
    });

    //THIS DOES NOT WORK BECAUSE TRUFFLE RESULT GAS IS ROUNDED
    //it("test Deposit and Withdraw Ether", function () {
    //    var myExchangeInstance;
    //    var balanceBeforeTransaction = web3.eth.getBalance(accounts[0]);
    //    var balanceAfterDeposit;
    //    var balanceAfterWithdrawal;
    //    var gasUsed = 0;
    //
    //    return exchange.deployed().then(function (instance) {
    //        myExchangeInstance = instance;
    //        return myExchangeInstance.depositEther({from: accounts[0], value: web3.toWei(1, "ether")});
    //    }).then(function (txHash) {
    //        gasUsed += txHash.receipt.cumulativeGasUsed * web3.eth.getTransaction(txHash.receipt.transactionHash).gasPrice.toNumber();
    //        balanceAfterDeposit = web3.eth.getBalance(accounts[0]);
    //        return myExchangeInstance.getEthBalanceInWei.call();
    //    }).then(function (balanceInWei) {
    //        assert.equal(balanceInWei.toNumber(), web3.toWei(1, "ether"), "There is one ether available");
    //        assert.equal(web3.toWei(1, "ether"), balanceBeforeTransaction.toNumber() - balanceAfterDeposit.toNumber() - gasUsed, "Balances of account are the same");
    //        return myExchangeInstance.withdrawEther(web3.toWei(1, "ether"));
    //    }).then(function (txHash) {
    //        balanceAfterWithdrawal = web3.eth.getBalance(accounts[0]);
    //        return myExchangeInstance.getEthBalanceInWei.call();
    //    }).then(function (balanceInWei) {
    //        assert.equal(balanceInWei.toNumber(), 0, "There is one ether available");
    //        assert.equal(balanceBeforeTransaction.toNumber(), balanceAfterWithdrawal.toNumber(), "There is one ether available");
    //
    //    });
    //});

    it("should be possible to Deposit and Withdrawal Ether", function () {
        var myExchangeInstance;
        var balanceBeforeTransaction = web3.eth.getBalance(accounts[0]);
        var balanceAfterDeposit;
        var balanceAfterWithdrawal;
        var gasUsed = 0;

        return exchange.deployed().then(function (instance) {
            myExchangeInstance = instance;
            return myExchangeInstance.depositEther({from: accounts[0], value: web3.toWei(1, "ether")});
        }).then(function (txHash) {
            gasUsed += txHash.receipt.cumulativeGasUsed * web3.eth.getTransaction(txHash.receipt.transactionHash).gasPrice.toNumber(); //here we have a problem
            balanceAfterDeposit = web3.eth.getBalance(accounts[0]);
            return myExchangeInstance.getEthBalanceInWei.call();
        }).then(function (balanceInWei) {
            assert.equal(balanceInWei.toNumber(), web3.toWei(1, "ether"), "There is one ether available");
            assert.isAtLeast(balanceBeforeTransaction.toNumber() - balanceAfterDeposit.toNumber(), web3.toWei(1, "ether"),  "Balances of account are the same");
            return myExchangeInstance.withdrawEther(web3.toWei(1, "ether"));
        }).then(function (txHash) {
            balanceAfterWithdrawal = web3.eth.getBalance(accounts[0]);
            return myExchangeInstance.getEthBalanceInWei.call();
        }).then(function (balanceInWei) {
            assert.equal(balanceInWei.toNumber(), 0, "There is no ether available anymore");
            assert.isAtLeast(balanceAfterWithdrawal.toNumber(), balanceBeforeTransaction.toNumber() - gasUsed*2, "There is one ether available");

        });
    });


    it("should be possible to Deposit Token", function () {
        var myExchangeInstance;
        var myTokenInstance;
        return fixedSupplyToken.deployed().then(function (instance) {
            myTokenInstance = instance;
            return instance;
        }).then(function (tokenInstance) {
            myTokenInstance = tokenInstance;
            return exchange.deployed();
        }).then(function (exchangeInstance) {
            myExchangeInstance = exchangeInstance;
            return myTokenInstance.approve(myExchangeInstance.address, 2000);
        }).then(function(txResult) {
            return myExchangeInstance.depositToken("FIXED", 2000);
        }).then(function(txResult) {
            return myExchangeInstance.getBalance("FIXED");
        }).then(function(balanceToken) {
            assert.equal(balanceToken, 2000, "There should be 2000 tokens for the address");
        });
    });

    it("should be possible to Withdraw Token", function () {
        var myExchangeInstance;
        var myTokenInstance;
        var balancedTokenInExchangeBeforeWithdrawal;
        var balanceTokenInTokenBeforeWithdrawal;
        var balanceTokenInExchangeAfterWithdrawal;
        var balanceTokenInTokenAfterWithdrawal;

        return fixedSupplyToken.deployed().then(function (instance) {
            myTokenInstance = instance;
            return instance;
        }).then(function (tokenInstance) {
            myTokenInstance = tokenInstance;
            return exchange.deployed();
        }).then(function (exchangeInstance) {
            myExchangeInstance = exchangeInstance;
            return myExchangeInstance.getBalance.call("FIXED");
        }).then(function(balanceExchange) {
            balancedTokenInExchangeBeforeWithdrawal = balanceExchange.toNumber();
            return  myTokenInstance.balanceOf.call(accounts[0]);
        }).then(function(balanceToken) {
            balanceTokenInTokenBeforeWithdrawal = balanceToken.toNumber();
            return myExchangeInstance.withdrawToken("FIXED", balancedTokenInExchangeBeforeWithdrawal);
        }).then(function(txResult) {
            return myExchangeInstance.getBalance.call("FIXED");
        }).then(function(balanceExchange) {
            balanceTokenInExchangeAfterWithdrawal = balanceExchange.toNumber();
            return  myTokenInstance.balanceOf.call(accounts[0]);
        }).then(function(balanceToken) {
            balanceTokenInTokenAfterWithdrawal = balanceToken.toNumber();
            assert.equal(balanceTokenInExchangeAfterWithdrawal, 0, "There should be 0 tokens left in the exchange");
            assert.equal(balanceTokenInTokenAfterWithdrawal, balancedTokenInExchangeBeforeWithdrawal + balanceTokenInTokenBeforeWithdrawal, "There should be 0 tokens left in the exchange");
        });
    });

});
