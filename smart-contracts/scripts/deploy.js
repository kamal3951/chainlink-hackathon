const { ethers } = require("ethers");
const main = async () => {

  const P2P = await hre.ethers.getContractFactory("p2p");
  console.log('Deploying contract p2p.sol');
  const p2p = await P2P.deploy();
  await p2p.deployed();
  console.log("Contract deployed to:", p2p.address);

  //const accounts = await ethers.provider.listAccounts();
  //console.log(accounts);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
