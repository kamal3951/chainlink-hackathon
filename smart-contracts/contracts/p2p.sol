//SPDX-License-Identifier:MIT
pragma solidity >0.8.4;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "../node_modules/@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

import "../node_modules/hardhat/console.sol";

import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/Ip2p.sol";

error p2p__TransferFailed();

contract p2p is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _ourContractTokenId;
    Counters.Counter private soldItems;

    //Token allowed to stake
    IERC721 public immutable listingToken;
    //ERC20 allowed to lend
    IERC20 public immutable lendingMoney;

    //struct listing
    struct listing {
        address payable listerAddress;
        uint256 tokenIdListed;
        uint256 LoanAmount;
        uint256 LoanTimePeriod;
        uint256 ourContractTokenId;
        bool isStaked;
        address currentOwner;
        address stakedTo;
    }

    mapping(uint256 => listing) allListedNftsByTokenId;

    //Total worth of supplied nfts
    uint256 public totalTokenSupplyWorth;

    //money used for loan
    uint256 public totalLoanMoney;

    constructor(address _listingTokenAddress, address _lendingMoneyAddress) {
        listingToken = IERC721(_listingTokenAddress);
        //UniswapV3 Rinkeby Adddress 0xC36442b4a4522E871399CD717aBDD847Ab11FE88
        lendingMoney = IERC20(_lendingMoneyAddress);
        //Rinkeby DAI Address
    }

    event ListNft(uint256 tokenId, uint256 LoanAmount, uint256 LoanTimePeriod);
    event LendMoney(listing Listing);

    function listNft(
        uint256 tokenId,
        uint256 LoanAmount,
        uint256 LoanTimePeriod
    ) external returns (bool) {
        _ourContractTokenId.increment();
        uint256 ourContractTokenId = _ourContractTokenId.current();

        //fetch the liquidity and set amount < 0.5 * liquidity
        uint256 NftLiquidity;
        listingToken.position(tokenId) = (, , , , , , , NftLiquidity, , , , );
        require(
            LoanAmount < NftLiquidity / 2,
            "You can not get loan of more than 50% worth of your position's liquidity"
        );
        listing memory Listing = new listing(
            msg.sender,
            tokenId,
            LoanAmount,
            LoanTimePeriod,
            ourContractTokenId,
            false,
            msg.sender,
            address(0)
        );
        bool success = listingToken[tokenId].safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        allListedNftsByTokenId[ourContractTokenId] = Listing;

        totalTokenSupplyWorth += uint256(NftLiquidity);

        if (!success) {
            revert p2p__TransferFailed();
        }

        emit ListNft(tokenId, LoanAmount, LoanTimePeriod);
    }

    function lendMoney(listing memory Listing) external returns (bool) {
        Listing.currentOwner = address(this);
        Listing.stakedTo = msg.sender;

        totalLoanMoney += Listing.LoanAmount;

        bool success = lendingMoney.transferFrom(
            msg.sender,
            Listing.listerAddress,
            Listing.LoanAmount
        );

        Listing.isStaked = true;

        if (!success) {
            revert p2p__TransferFailed();
        }

        emit LendMoney(Listing);
    }

    function getLoansDispersedByUser() external returns (listing[] memory) {
        listing[] memory ListingThatIsLended;
        for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
            if (allListedNftsByTokenId[i].stakedTo == msg.sender) {
                ListingThatIsLended.push(allListedNftsByTokenId[i]);
            }
        }
        return ListingThatIsLended;
    }

    function getListedNftsByUser() external returns (listing[] memory) {
        listing[] memory listedButNotStakedYet;

        for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
            if (
                allListedNftsByTokenId[i].listerAddress == msg.sender &&
                allListedNftsByTokenId[i].isStaked == false
            ) {
                listedButNotStakedYet.push(allListedNftsByTokenId);
            }
        }
        return listedButNotStakedYet;
    }

    function getStakedNftsByUser() external returns (listing[] memory) {
        listing[] memory listedAndStaked;
        for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
            if (
                allListedNftsByTokenId[i].listerAddress == msg.sender &&
                allListedNftsByTokenId[i].isStaked == true
            ) {
                listedAndStaked.push(allListedNftsByTokenId);
            }
        }
        return listedAndStaked;
    }

    //MAKE THIS FUNCTION TO AS REPAY-LOAN
    function repayLoan(uint256 tokenId) external returns (bool) {
        require();
    }

    //function claimInterestOverLending() external returns (bool) {}
}
