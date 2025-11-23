const ProductVerification = artifacts.require("ProductVerification");

module.exports = function (deployer) {
  deployer.deploy(ProductVerification);
};
