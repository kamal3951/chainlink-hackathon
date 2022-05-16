//SPDX-License-Identifier:MIT
pragma solidity >0.8.4;

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "../node_modules/@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

error p2p__TransferFailed();

contract p2p is ReentrancyGuard {
    //Token allowed to stake
    IERC721 public immutable listingToken;
    //ERC20 allowed to lend
    IERC20 public immutable lendingMoney;

    //struct listing
    struct listing {
        address payable listerAddress;
        uint128 tokenIdListed;
        uint128 LoanAmount;
        uint256 LoanTimePeriod;
    }
    //mapping of lister to listed struct
    mapping(address => listing[]) listerAddressToListedStruct;

    //struct lending
    struct lending {
        address payable lenderAddress;
        uint256 tokenId;
        uint128 amountLendedToNftOwner;
        //uint128 returnRate;
    }

    //lender to lending
    mapping(address => lending[]) lenderAddressToLendingStructArray;

    //Total worth of supplied nfts
    uint256 public totalTokenSupplyWorth;

    //money used for loan
    uint256 public totalLoanMoney;

    //modifier updateReward(address account) {}

    constructor(address _listingTokenAddress, address _lendingMoneyAddress) {
        //listingToken = IERC721("0xC36442b4a4522E871399CD717aBDD847Ab11FE88"); //UniswapV3 Rinkeby Adddress
        listingToken = IERC721(_listingTokenAddress);
        lendingMoney = IERC20(_lendingMoneyAddress); //Rinkeby DAI Address
    }

    function listNft(
        uint256 tokenId,
        uint256 LoanAmount,
        uint256 LoanTimePeriod
    ) external returns (bool) {
        //fetch the liquidity and set amount < 0.5 * liquidity
        uint256 NftLiquidity;
        listingToken.position(tokenId) = (, , , , , , , NftLiquidity, , , , );
        require(
            LoanAmount < NftLiquidity / 2,
            "You can not get loan of more than 50% worth of your position's liquidity"
        );
        listing storage Listing = listing(
            msg.sender,
            tokenId,
            LoanAmount,
            LoanTimePeriod
        );
        bool success = listingToken[tokenId].safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        listerAddressToListedStruct[msg.sender].push(Listing);

        totalTokenSupplyWorth += uint256(NftLiquidity);
        if (!success) {
            revert p2p__TransferFailed();
        }
    }

    function lendMoney(listing memory Listing) external returns (bool) {
        lending storage Lending = lending(
            msg.sender,
            Listing.tokenIdListed,
            Listing.LoanAmount
        );

        lenderAddressToLendingStructArray[msg.sender].push(Lending);

        totalLoanMoney += Listing.LoanAmount;

        bool success = lendingMoney.transferFrom(
            msg.sender,
            Listing.listerAddress,
            Listing.LoanAmount
        );

        if (!success) {
            revert p2p__TransferFailed();
        }
    }

    /*function withdrawMoney(uint256 amount) external returns (bool) {
        require(amount <= MoneyLendedByUser[msg.sender]);
        MoneyLendedByUser[msg.sender] -= amount;
        bool success = lendingMoney.transfer(msg.sender, amount);
        //ULTERC20._burn(msg.sender, amount);
        if (!success) {
            revert p2p__TransferFailed();
        }
    }*/

    function unstakeNFT() external returns (bool) {}

    //MAKE THIS FUNCTION TO AS REPAY-LOAN
    /*function withdrawNft(uint256 tokenId) external returns (bool) {
        if (NftLendedByUser[msg.sender].length == 1) {
            NftsLendedByUser[msg.sender][tokenId].pop();
            AllLenders[msg.sender].pop();
        }
        NftsLendedByUser[msg.sender][tokenId].pop();
        bool success = stakingToken[tokenId].safeTransfer(msg.sender, tokenId);
        totalTokenSupplyWorth -= uint256(stakingTokens[tokenId].liquidity);
        if (!success) {
            revert p2p__TransferFailed();
        }
    }*/

    function claimInterestOverLending() external returns (bool) {}
}
