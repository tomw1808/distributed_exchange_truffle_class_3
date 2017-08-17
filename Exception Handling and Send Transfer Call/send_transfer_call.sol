pragma solidity ^0.4.13;

contract someContract {
    
    mapping(address => uint) balances;
    
    function deposit() payable {
        balances[msg.sender] += msg.value;
    }
    
    //VERY very bad below
    function withdrawVeryBad1(uint amount) {
        if(balances[msg.sender] >= amount) {
            msg.sender.send(amount);
            balances[msg.sender] -= amount;
        }
    }
    function withdrawVeryVeryBad2(uint amount) {
        if(balances[msg.sender] >= amount) {
            msg.sender.call.gas(2500000).value(amount)();
            balances[msg.sender] -= amount;
        }
    }
    function withdrawVeryVeryBad3(uint amount) {
        if(balances[msg.sender] >= amount) {
            if(msg.sender.call.gas(2500000).value(amount)()) {
                balances[msg.sender] -= amount;
            }
        }
    }
    
    function withdrawBad1(uint amount) {
        if(balances[msg.sender] >= amount) {
            if(msg.sender.send(amount)) {
                balances[msg.sender] -= amount;
            }
        }
    }
    
    function withdrawOkayish(uint amount) {
        if(balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            if(!msg.sender.send(amount)) {
               throw;
            }
        }
    }
    function withdrawBad2(uint amount) {
        if(balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            if(!msg.sender.call.gas(2500000).value(amount)()) {
               throw;
            }
        }
    }
    
    
    //OKAY FUNCTIONS
    
    function withdrawOK(uint amount) {
        if(balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            msg.sender.transfer(amount);
        }
    }
    
    //New Exception handling
    function withdrawGood(uint amount) {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
}