const main = async () => {
  const UniV3NftCollateral = await hre.ethers.getContractFactory('UniV3NftCollateral');
  const nftContract = await UniV3NftCollateral.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);
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
