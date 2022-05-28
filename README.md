[![built-with Chainlink](https://img.shields.io/badge/built%20with-Chainlink-4045C9)](https://nextjs.org/)
[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)
[![built-with Uniswap](https://img.shields.io/badge/built%20with-Uniswap-D656D2)](https://github.com/Uniswap)
[![built-with Moralis](https://img.shields.io/badge/built%20with-Moralis-749FDB)](https://moralis.io/)
[![built-with Nextjs](https://img.shields.io/badge/built%20with-Nextjs-04020D)](https://nextjs.org/)

# UniswapV3 NFTs as a collateral for loans

This project implements peer-to-peer mechanicsm of giving out a loan and listing an UniswapV3 NFT as a collateral.
It is participating project for Chainlink Spring Hackathon 2022.

## Borrowing Loan (Staking NFT)

All the UniswapV3 LP NFTs owned by the user are listed on the Borrow page, the user can list any of his NFT for a loan with specifiying the `LoanTime` and `LoanAmount`.
The `LoanAmount` must be less than the 50% value of the LP Token i.e., NFT's underlying liquidity.

## Lending Money

All the NFTs that are listed by all the users over the platfrom are displayed on the `Lend` page.
The user can provide loan in DAI to the NFT owners, getting returns from the interest earned from that NFT from Uniswap.

# How to run the dapp
1. Clone the project
2. Run `yarn install` in the client directory
4. Run `yarn dev` in the client directory.
5. The dapp will be live at localhost, you can list your UniswapV3 LP token on the `Borrow` page.
6. You can also lend money on the `Lend` page 


