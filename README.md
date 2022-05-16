# UniswapV3 NFTs as a collateral for loans

This porject implements peer-to-peer mechanicsm of giving out a loan and listing an UniswapV3 NFT as a collateral.
##Borrowing Loan (Staking NFT)
All the UniswapV3 LP NFTs are listed on the Borrow page, the user can list any of his NFT for a loan with specifiying the `LoanTime` and `LoanAmount`.
The LoanAmount must be less than the 50% value of the LP Token i.e., NFT's underlying liquidity.

##Lending Money
All the NFTs that are listed by all the users are displayed on the `Lend` page.
The user can provide loan in DAI to the NFT owners, getting returns from the interest earned from that NFT from Uniswap.
