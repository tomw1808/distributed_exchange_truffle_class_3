pragma solidity ^0.4.13;


contract secondContract {
    uint public number = 0;
    
    function increaseNumber() {
        number++;
    }
    
    
    function thisThrowsARevert() {
        revert();
    }
    
    
    function() payable {
        thisThrowsARevert();
    }
}


contract TestRevertAssert {
    
    secondContract _secondContract;
    
    function TestRevertAssert() {
        _secondContract = new secondContract();
    }
    
    mapping(address => uint) balance;
    
    ////////////////////////////////
    // ASSERT STYLE: ALL GAS USED //
    ////////////////////////////////
    function assertExceptionArrayTooLarge() {
        uint[] memory myArray = new uint[](10);
        myArray[11] = 10;
    }
    
    
    function divideByZero() {
        uint someVar = 0;
        uint someOtherVar = 50;
        uint third = someOtherVar / someVar;
        third = 1;
    }
    
    function shiftByNegativeAmount() {
        uint someVar = 1;
        int shiftVar = -1;
        someVar << shiftVar;
    }
    
    
    function thisAsserts() {
        assert(false); //consumes all gas
    }
    
    ////////////////////////////////
    // REQUIRE STYLE: RETURNS GAS //
    ////////////////////////////////
    
    
    function thisThrows() {
        throw; //require-style exception
    }
    
    function thisRequires() {
        require(false); //consumes no gas
    }
    
    function thisReverts() {
        revert();
    }
    
    
    function throwInSecondContract() {
        _secondContract.thisThrowsARevert();
    }
    
    
    function callSendContractWithTransfer() payable {
        _secondContract.transfer(msg.value);
    }
    
    function changeWithRevert() {
        _secondContract.increaseNumber();
        revert();
    }
    
    function safeWithdraw(uint amount) {
        require(balance[msg.sender] >= amount);
        require(balance[msg.sender] - amount <= balance[msg.sender]);
        balance[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
    
    /////////////////////////
    // DANGER ZONE BELOW!! //
    /////////////////////////
    
    function callSecondContract() payable {
        _secondContract.call.gas(100000).value(msg.value)(msg.data);
    }
    
    
    function sendFundsToSecondContract() payable {
        _secondContract.send(msg.value);
        
    }
    
    
    //////////////////////
    // NORMAL FUNCTIONS //
    //////////////////////
    function getNumber() constant returns(uint) {
        return _secondContract.number();
    }
    
    function changeWithoutRevert() {
        _secondContract.increaseNumber();
    }
    
    function depositFunds() payable {
        //overflow check
        uint new_balance = msg.value;
        require(balance[msg.sender] + msg.value >= balance[msg.sender]);
        balance[msg.sender] += new_balance;
    }
    
}
