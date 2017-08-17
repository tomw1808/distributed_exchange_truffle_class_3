pragma solidity ^0.4.13;

contract TestRevertAssert {
    
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
    
}
