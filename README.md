[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)
[![built-with Uniswap](https://img.shields.io/badge/built%20with-Uniswap-3677FF)](https://github.com/Uniswap)

# UniswapV3 NFTs as a collateral for loans

This project implements peer-to-peer mechanicsm of giving out a loan and listing an UniswapV3 NFT as a collateral.
It is participating project for Chainlink Spring Hackathon 2022.

## Borrowing Loan (Staking NFT)

All the UniswapV3 LP NFTs owned by the user are listed on the Borrow page, the user can list any of his NFT for a loan with specifiying the `LoanTime` and `LoanAmount`.
The `LoanAmount` must be less than the 50% value of the LP Token i.e., NFT's underlying liquidity.

## Lending Money

All the NFTs that are listed by all the users over the platfrom are displayed on the `Lend` page.
The user can provide loan in DAI to the NFT owners, getting returns from the interest earned from that NFT from Uniswap.


