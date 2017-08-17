var FixedSupplyToken = artifacts.require("./FixedSupplyToken.sol");


module.exports = function(deployer) {
  deployer.deploy(FixedSupplyToken);
};
