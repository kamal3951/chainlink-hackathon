//SPDX-License-Identifier:MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../node_modules/@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "../node_modules/@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";

error p2p__TransferFailed();

contract p2p is IERC721Receiver, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _listingId;
    Counters.Counter private _listedItems;
    Counters.Counter private _stakedItems;

    Counters.Counter _userLoanCount;
    Counters.Counter _userListingCount;
    Counters.Counter _userStakingCount;

    Counters.Counter _allNftsAvailableToBeStakedCount;

    address payable owner;

    //Token allowed to stake
    INonfungiblePositionManager public immutable listingToken;
    //ERC20 allowed to lend
    IERC20 public immutable lendingMoney;

    //struct listing
    struct listing {
        address listerAddress;
        uint256 tokenId;
        uint256 LoanAmount;
        uint256 LoanTimePeriod;
        uint256 listingId;
        bool isStaked;
        address stakedTo;
    }

    event NftListed(
        address listerAddress,
        uint256 tokenIdListed,
        uint256 LoanAmount,
        uint256 LoanTimePeriod,
        uint256 lisitngId,
        bool isStaked,
        address stakedTo
    );

    mapping(uint256 => listing) allListedNftsByTokenId;

    //Total worth of supplied nfts
    uint256 public totalTokenSupplyWorth;

    //Total money supplied for loan
    uint256 public totalLoanMoney;

    constructor(address _listingTokenAddress) {
        listingToken = INonfungiblePositionManager(_listingTokenAddress);
        //UniswapV3 Kovan Adddress
        lendingMoney = IERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);
        //Kovan DAI Address
    }

    function listNft(
        uint256 tokenId,
        uint256 LoanAmount,
        uint256 LoanTimePeriod
    ) external nonReentrant {
        _listingId.increment();
        _listedItems.increment();

        //fetch the liquidity and set amount < 0.5 * liquidity
        uint256 NftLiquidity;
        (, , , , , , , NftLiquidity, , , , ) = listingToken.positions(tokenId);
        require(
            LoanAmount < NftLiquidity / 2,
            "You can not get loan of more than 50% worth of your position's liquidity"
        );

        //listingToken.approve(address(this), tokenId);
        //approving will be done from frontend
        listingToken.safeTransferFrom(msg.sender, address(this), tokenId);

        allListedNftsByTokenId[_listingId.current()] = listing(
            payable(msg.sender),
            tokenId,
            LoanAmount,
            LoanTimePeriod,
            _listingId.current(),
            false,
            payable(msg.sender)
        );

        totalTokenSupplyWorth += uint256(NftLiquidity);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function lendMoney(uint256 listingId) external payable returns (bool) {
        listing storage _listing = allListedNftsByTokenId[listingId];
        require(
            msg.value == _listing.LoanAmount,
            "Please supply the sufficient loan amount"
        );
        require(
            msg.sender != _listing.listerAddress,
            "Seller can not buy its own tokens"
        );

        _listing.isStaked = true;
        _listing.stakedTo = msg.sender;

        lendingMoney.approve(
            address(this),
            allListedNftsByTokenId[listingId].LoanAmount
        );

        bool success = lendingMoney.transferFrom(
            msg.sender,
            address(this),
            allListedNftsByTokenId[listingId].LoanAmount
        );

        return success;
    }

    //Getter functions
    function getLoansDispersedByUser() external returns (listing[] memory) {
        listing[] memory ListingThatIsLended;
        _userLoanCount.reset();
        for (uint256 i = 0; i < listingId.current(); i++) {
            if (allListedNftsByTokenId[i].stakedTo == msg.sender) {
                ListingThatIsLended[
                    _userLoanCount.current()
                ] = allListedNftsByTokenId[i];
            }
            _userLoanCount.increment();
        }
        return ListingThatIsLended;
    }

    function getListedNftsByUser() external returns (listing[] memory) {
        listing[] memory listedButNotStakedYet;
        _userListingCount.reset();
        for (uint256 i = 0; i < listingId.current(); i++) {
            if (
                allListedNftsByTokenId[i].listerAddress == msg.sender &&
                allListedNftsByTokenId[i].isStaked == false
            ) {
                listedButNotStakedYet[
                    _userListingCount.current()
                ] = allListedNftsByTokenId[i];
            }
            _userListingCount.increment();
        }
        return listedButNotStakedYet;
    }

    function getStakedNftsByUser() external returns (listing[] memory) {
        listing[] memory listedAndStaked;
        _userStakingCount.reset();
        for (uint256 i = 0; i < listingId.current(); i++) {
            if (
                allListedNftsByTokenId[i].listerAddress == msg.sender &&
                allListedNftsByTokenId[i].isStaked == true
            ) {
                listedAndStaked[
                    _userStakingCount.current()
                ] = allListedNftsByTokenId[i];
            }
            _userStakingCount.increment();
        }
        return listedAndStaked;
    }

    function getAllNftsListedAvailableToBeStaked()
        external
        returns (listing[] memory)
    {
        listing[] memory AllNftsListedAvailableToBeStaked;
        _allNftsAvailableToBeStakedCount.reset();
        for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
            if (allListedNftsByTokenId[i].isStaked == false) {
                AllNftsListedAvailableToBeStaked[
                    _allNftsAvailableToBeStakedCount.current()
                ] = allListedNftsByTokenId[i];
            }
        }
        return AllNftsListedAvailableToBeStaked;
    }
}
