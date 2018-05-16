var FixedSupplyToken = artifacts.require("FixedSupplyToken");
var Exchange = artifacts.require("Exchange");
var owned = artifacts.require("owned");
module.exports = function (deployer) {
  deployer.deploy(FixedSupplyToken);
  deployer.deploy(Exchange);
  deployer.deploy(owned);
};
