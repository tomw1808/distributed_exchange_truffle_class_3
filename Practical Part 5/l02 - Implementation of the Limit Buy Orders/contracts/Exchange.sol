pragma solidity ^0.4.13;


import "./owned.sol";
import "./FixedSupplyToken.sol";


contract Exchange is owned {

    ///////////////////////
    // GENERAL STRUCTURE //
    ///////////////////////
    struct Offer {

    uint amount;
    address who;
    }

    struct OrderBook {

    uint higherPrice;
    uint lowerPrice;

    mapping (uint => Offer) offers;

    uint offers_key;
    uint offers_length;
    }

    struct Token {

    address tokenContract;

    string symbolName;


    mapping (uint => OrderBook) buyBook;

    uint curBuyPrice;
    uint lowestBuyPrice;
    uint amountBuyPrices;


    mapping (uint => OrderBook) sellBook;
    uint curSellPrice;
    uint highestSellPrice;
    uint amountSellPrices;

    }


    //we support a max of 255 tokens...
    mapping (uint8 => Token) tokens;

    uint8 symbolNameIndex;


    //////////////
    // BALANCES //
    //////////////
    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;




    ////////////
    // EVENTS //
    ////////////

    //EVENTS for Deposit/withdrawal
    event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event WithdrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event DepositForEthReceived(address indexed _from, uint _amount, uint _timestamp);
    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

    //events for orders
    event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
    event SellOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
    event SellOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);
    event LimitBuyOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokens, uint _priceInWei, uint _orderKey);
    event BuyOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
    event BuyOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);

    //events for management
    event TokenAddedToSystem(uint _symbolIndex, string _token, uint _timestamp);



    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL ETHER //
    //////////////////////////////////
    function depositEther() payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] += msg.value;
        DepositForEthReceived(msg.sender, msg.value, now);
    }

    function withdrawEther(uint amountInWei) {
        require(balanceEthForAddress[msg.sender] - amountInWei >= 0);
        require(balanceEthForAddress[msg.sender] - amountInWei <= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
        WithdrawalEth(msg.sender, amountInWei, now);
    }

    function getEthBalanceInWei() constant returns (uint){
        return balanceEthForAddress[msg.sender];
    }


    //////////////////////
    // TOKEN MANAGEMENT //
    //////////////////////

    function addToken(string symbolName, address erc20TokenAddress) onlyowner {
        require(!hasToken(symbolName));
        require(symbolNameIndex + 1 > symbolNameIndex);
        symbolNameIndex++;

        tokens[symbolNameIndex].symbolName = symbolName;
        tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
        TokenAddedToSystem(symbolNameIndex, symbolName, now);
    }

    function hasToken(string symbolName) constant returns (bool) {
        uint8 index = getSymbolIndex(symbolName);
        if (index == 0) {
            return false;
        }
        return true;
    }


    function getSymbolIndex(string symbolName) internal returns (uint8) {
        for (uint8 i = 1; i <= symbolNameIndex; i++) {
            if (stringsEqual(tokens[i].symbolName, symbolName)) {
                return i;
            }
        }
        return 0;
    }


    function getSymbolIndexOrThrow(string symbolName) returns (uint8) {
        uint8 index = getSymbolIndex(symbolName);
        require(index > 0);
        return index;
    }







    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL TOKEN //
    //////////////////////////////////
    function depositToken(string symbolName, uint amount) {
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        require(tokens[symbolNameIndex].tokenContract != address(0));

        ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

        require(token.transferFrom(msg.sender, address(this), amount) == true);
        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] + amount >= tokenBalanceForAddress[msg.sender][symbolNameIndex]);
        tokenBalanceForAddress[msg.sender][symbolNameIndex] += amount;
        DepositForTokenReceived(msg.sender, symbolNameIndex, amount, now);
    }

    function withdrawToken(string symbolName, uint amount) {
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        require(tokens[symbolNameIndex].tokenContract != address(0));

        ERC20Interface token = ERC20Interface(tokens[symbolNameIndex].tokenContract);

        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount >= 0);
        require(tokenBalanceForAddress[msg.sender][symbolNameIndex] - amount <= tokenBalanceForAddress[msg.sender][symbolNameIndex]);

        tokenBalanceForAddress[msg.sender][symbolNameIndex] -= amount;
        require(token.transfer(msg.sender, amount) == true);
        WithdrawalToken(msg.sender, symbolNameIndex, amount, now);
    }

    function getBalance(string symbolName) constant returns (uint) {
        uint8 symbolNameIndex = getSymbolIndexOrThrow(symbolName);
        return tokenBalanceForAddress[msg.sender][symbolNameIndex];
    }





    /////////////////////////////
    // ORDER BOOK - BID ORDERS //
    /////////////////////////////
    function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {
    }


    /////////////////////////////
    // ORDER BOOK - ASK ORDERS //
    /////////////////////////////
    function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {
    }





    ////////////////////////////
    // NEW ORDER - BID ORDER //
    ///////////////////////////
    function buyToken(string symbolName, uint priceInWei, uint amount) {
        uint8 tokenNameIndex = getSymbolIndexOrThrow(symbolName);
        uint total_amount_ether_necessary = 0;
        uint total_amount_ether_available = 0;

        //if we have enough ether, we can buy that:
        total_amount_ether_necessary = amount*priceInWei;

        //overflow check
        require(total_amount_ether_necessary >= amount);
        require(total_amount_ether_necessary >= priceInWei);
        require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary);
        require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary >= 0);

        //first deduct the amount of ether from our balance
        balanceEthForAddress[msg.sender] -= total_amount_ether_necessary;


        if (tokens[tokenNameIndex].amountSellPrices == 0 || tokens[tokenNameIndex].curSellPrice > priceInWei) {
            //limit order: we don't have enough offers to fulfill the amount

            //add the order to the orderBook
            addBuyOffer(tokenNameIndex, priceInWei, amount, msg.sender);
            //and emit the event.
            LimitBuyOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, tokens[tokenNameIndex].buyBook[priceInWei].offers_length);
        } else {
            //market order: current sell price is smaller or equal to buy price!

            revert(); //just for now, throw an exception
        }
    }


    ///////////////////////////
    // BID LIMIT ORDER LOGIC //
    ///////////////////////////
    function addBuyOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
        tokens[tokenIndex].buyBook[priceInWei].offers_length++;
        tokens[tokenIndex].buyBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount, who);


        if (tokens[tokenIndex].buyBook[priceInWei].offers_length == 1) {
            tokens[tokenIndex].buyBook[priceInWei].offers_key = 1;
            //we have a new buy order - increase the counter, so we can set the getOrderBook array later
            tokens[tokenIndex].amountBuyPrices++;


            //lowerPrice and higherPrice have to be set
            uint curBuyPrice = tokens[tokenIndex].curBuyPrice;

            uint lowestBuyPrice = tokens[tokenIndex].lowestBuyPrice;
            if (lowestBuyPrice == 0 || lowestBuyPrice > priceInWei) {
                if (curBuyPrice == 0) {
                    //there is no buy order yet, we insert the first one...
                    tokens[tokenIndex].curBuyPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                } else {
                    //or the lowest one
                    tokens[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
                    tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                }
                tokens[tokenIndex].lowestBuyPrice = priceInWei;
            }
            else if (curBuyPrice < priceInWei) {
                //the offer to buy is the highest one, we don't need to find the right spot
                tokens[tokenIndex].buyBook[curBuyPrice].higherPrice = priceInWei;
                tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
                tokens[tokenIndex].buyBook[priceInWei].lowerPrice = curBuyPrice;
                tokens[tokenIndex].curBuyPrice = priceInWei;

            }
            else {
                //we are somewhere in the middle, we need to find the right spot first...

                uint buyPrice = tokens[tokenIndex].curBuyPrice;
                bool weFoundIt = false;
                while (buyPrice > 0 && !weFoundIt) {
                    if (
                    buyPrice < priceInWei &&
                    tokens[tokenIndex].buyBook[buyPrice].higherPrice > priceInWei
                    ) {
                        //set the new order-book entry higher/lowerPrice first right
                        tokens[tokenIndex].buyBook[priceInWei].lowerPrice = buyPrice;
                        tokens[tokenIndex].buyBook[priceInWei].higherPrice = tokens[tokenIndex].buyBook[buyPrice].higherPrice;

                        //set the higherPrice'd order-book entries lowerPrice to the current Price
                        tokens[tokenIndex].buyBook[tokens[tokenIndex].buyBook[buyPrice].higherPrice].lowerPrice = priceInWei;
                        //set the lowerPrice'd order-book entries higherPrice to the current Price
                        tokens[tokenIndex].buyBook[buyPrice].higherPrice = priceInWei;

                        //set we found it.
                        weFoundIt = true;
                    }
                    buyPrice = tokens[tokenIndex].buyBook[buyPrice].lowerPrice;
                }
            }
        }
    }




    ////////////////////////////
    // NEW ORDER - ASK ORDER //
    ///////////////////////////
    function sellToken(string symbolName, uint priceInWei, uint amount) {
    }



    //////////////////////////////
    // CANCEL LIMIT ORDER LOGIC //
    //////////////////////////////
    function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {
    }




    ////////////////////////////////
    // STRING COMPARISON FUNCTION //
    ////////////////////////////////
    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
bytes storage a = bytes(_a);
bytes memory b = bytes(_b);
if (a.length != b.length) {
return false;
}
// @todo unroll this loop
for (uint i = 0; i < a.length; i ++) {
if (a[i] != b[i]) {
return false;
}
}
return true;
}


}