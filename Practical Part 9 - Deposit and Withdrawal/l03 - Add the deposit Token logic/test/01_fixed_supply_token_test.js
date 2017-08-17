var fixedSupplyToken = artifacts.require("./FixedSupplyToken.sol");

contract('MyToken', function(accounts) {
    it("first account should own all tokens", function() {
        var _totalSupply;
        var myTokenInstance;
        return fixedSupplyToken.deployed().then(function(instance) {
            myTokenInstance = instance;
            return myTokenInstance.totalSupply.call();
        }).then(function(totalSupply) {
            _totalSupply = totalSupply;
            return myTokenInstance.balanceOf(accounts[0]);
        }).then(function(balanceAccountOwner) {
            assert.equal(balanceAccountOwner.toNumber(), _totalSupply.toNumber(), "Total Amount of tokens is owned by owner");
        });
    });

    it("second account should own no tokens", function() {
        var myTokenInstance;
        return fixedSupplyToken.deployed().then(function(instance) {
            myTokenInstance = instance;
            return myTokenInstance.balanceOf(accounts[1]);
        }).then(function(balanceAccountOwner) {
            assert.equal(balanceAccountOwner.toNumber(), 0, "Total Amount of tokens is owned by some other address");
        });
    });



    it("should send token correctly", function() {
        var token;

        //    Get initial balances of first and second account.
        var account_one = accounts[0];
        var account_two = accounts[1];

        var account_one_starting_balance;
        var account_two_starting_balance;
        var account_one_ending_balance;
        var account_two_ending_balance;

        var amount = 10;

        return fixedSupplyToken.deployed().then(function(instance) {
            token = instance;
            return token.balanceOf.call(account_one);
        }).then(function(balance) {
            account_one_starting_balance = balance.toNumber();
            return token.balanceOf.call(account_two);
        }).then(function(balance) {
            account_two_starting_balance = balance.toNumber();
            return token.transfer(account_two, amount, {from: account_one});
        }).then(function() {
            return token.balanceOf.call(account_one);
        }).then(function(balance) {
            account_one_ending_balance = balance.toNumber();
            return token.balanceOf.call(account_two);
        }).then(function(balance) {
            account_two_ending_balance = balance.toNumber();

            assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
            assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
        });
    });
});
