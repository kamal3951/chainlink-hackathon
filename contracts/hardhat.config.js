require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html


const RINKEBY_PRIVATE_KEY = "0x743a6a63199d341463f8cf6544778af8de8655faaaacd3d81b9074564a280c07";
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.7.6",
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/a2ddd0e37c4244b39c8e0b8d61823ec8`,
      accounts: [`${RINKEBY_PRIVATE_KEY}`]
    },
    kovan: {
      url: `https://kovan.infura.io/v3/77fec7e08400400f949aee7b1cbd5b7c`,
      accounts: [`${RINKEBY_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: 'Z4B8XEHDDWJ9X93GI41W199R81C1URAR78'
  },


  solidity: {
    version: "0.7.6",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
}
