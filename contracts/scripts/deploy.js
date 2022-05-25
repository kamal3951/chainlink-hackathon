const { ethers } = require("ethers");
const main = async () => {

  const UniV3NftLoan = await hre.ethers.getContractFactory("UniV3NftLoan");
  console.log('Deploying contract...');
  const univ3nftloan = await UniV3NftLoan.deploy();
  await univ3nftloan.deployed();
  console.log("Contract deployed to:", univ3nftloan.address);

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

