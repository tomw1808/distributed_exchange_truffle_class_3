//import jquery and bootstrap
import 'jquery';
import 'bootstrap-loader';
// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import exchange_artifacts from '../../build/contracts/Exchange.json'
import token_artifacts from '../../build/contracts/FixedSupplyToken.json'

// MetaCoin is our usable abstraction, which we'll use through the code below.
var ExchangeContract = contract(exchange_artifacts);
var TokenContract = contract(token_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;

window.App = {
  start: function() {
   //bootstrap everything
  },

  setStatus: function(message) {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },
  printImportantInformation: function() {
    //print out some important information
  },
  /**
   * Exchange specific functions here
   */
  initExchange: function() {
    //init Exchange

  },
  watchExchangeEvents: function() {
    //watch for Exchange Events
  },
  addTokenToExchange: function() {
	//function to add tokens to the exchange
  },
  refreshBalanceExchange: function() {
	//refresh your balance
  },
  depositEther: function() {
  	  //deposit ether function
  },
  withdrawEther: function() {
	//withdraw ether function
  },
  depositToken: function() {
	//deposit token function
  },
  /**
   * TRADING FUNCTIONS FROM HERE ON
   */
  initTrading: function() {
    App.refreshBalanceExchange();
    App.printImportantInformation();
    App.updateOrderBooks();
    App.listenToTradingEvents();
  },
  updateOrderBooks: function() {
    //update the order books function
  },
  listenToTradingEvents: function() {
//listen to trading events
  },
  sellToken: function() {
 //sell token
  },
  buyToken: function() {
//buy token
  },

  /**
   * TOKEN FUNCTIONS FROM HERE ON
   */
  initManageToken: function() {
    App.updateTokenBalance();
    App.watchTokenEvents();
    App.printImportantInformation();
  },
  updateTokenBalance: function() {
    //update the token balance
  },
  watchTokenEvents: function() {
    //watch for token events
  },

  sendToken: function() {
   //send tokens
  },

  allowanceToken: function() {
    //token allowance
  }
};

window.addEventListener('load', function() {
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.start();
});
