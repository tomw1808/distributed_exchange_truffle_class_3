var FixedSupplyToken = artifacts.require("./FixedSupplyToken.sol");
var Exchange = artifacts.require("./Exchange.sol");

module.exports = function(deployer) {
  deployer.deploy(FixedSupplyToken);
  deployer.deploy(Exchange);
};
