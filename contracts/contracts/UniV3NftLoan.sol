//SPDX-License-Identifier:MIT
pragma solidity >=0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

//error p2p__TransferFailed();

contract UniV3NftLoan is IERC721Receiver, ReentrancyGuard {
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
    INonfungiblePositionManager public constant listingToken =
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    //ERC20 allowed to lend
    IERC20 public constant lendingMoney =
        IERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);

    mapping(address => address) public borrowerToLender;
    mapping(address => uint128) public borrowerToLiquidity;
    mapping(address => uint256) public borrowerToTokenId;
    mapping(uint256 => address) public tokenIdToBorrower;
    mapping(uint256 => uint256) public tokenIdToListingId;
    //struct listing
    struct listing {
        address listerAddress;
        uint256 tokenId;
        uint256 LoanAmount;
        uint256 LoanTimePeriod;
        uint256 listingId;
        bool isStaked;
    }

    event NftListed(
        address listerAddress,
        uint256 tokenIdListed,
        uint256 LoanAmount,
        uint256 LoanTimePeriod,
        uint256 lisitngId,
        bool isStaked
    );

    mapping(uint256 => listing) allListedNftsByListingId;

    //Total worth of supplied nfts
    uint256 public totalTokenSupplyWorth;

    //Total money supplied for loan
    uint256 public totalLoanMoney;

    function listNft(
        uint256 tokenId,
        uint256 LoanTimePeriod,
        address payable borrower
    ) external nonReentrant {
        _listingId.increment();
        _listedItems.increment();

        (, , , , , , , uint128 NftLiquidity, , , , ) = listingToken.positions(
            tokenId
        );

        allListedNftsByListingId[_listingId.current()] = listing(
            borrower,
            tokenId,
            NftLiquidity / 2,
            LoanTimePeriod,
            _listingId.current(),
            false
        );

        totalTokenSupplyWorth += uint256(NftLiquidity);
        tokenIdToListingId[tokenId] = _listingId.current();
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

    function lendMoney(uint256 tokenId, address lender)
        external
        payable
        returns (bool)
    {
        uint256 listingId = tokenIdToListingId[tokenId];
        listing storage _listing = allListedNftsByListingId[listingId];
        require(
            msg.value == _listing.LoanAmount,
            "Please supply the sufficient loan amount"
        );
        require(
            lender != _listing.listerAddress,
            "Seller can not buy its own tokens"
        );

        _listing.isStaked = true;

        bool success = lendingMoney.transferFrom(
            lender,
            address(this),
            allListedNftsByListingId[listingId].LoanAmount
        );

        return success;
    }

    //Getter functions
    // function getLoansDispersedByUser() external returns (listing[] memory) {
    //     listing[] memory ListingThatIsLended;
    //     _userLoanCount.reset();
    //     // for (uint256 i = 0; i < _listingId.current(); i++) {
    //     //     if (allListedNftsByListingId[i].stakedTo == msg.sender) {
    //     //         ListingThatIsLended[
    //     //             _userLoanCount.current()
    //     //         ] = allListedNftsByListingId[i];
    //     //     }
    //     //     _userLoanCount.increment();
    //     // }
    //     return ListingThatIsLended;
    // }

    // function getListedNftsByUser() external returns (listing[] memory) {
    //     listing[] memory listedButNotStakedYet;
    //     _userListingCount.reset();
    //     for (uint256 i = 0; i < _listingId.current(); i++) {
    //         if (
    //             allListedNftsByListingId[i].listerAddress == msg.sender &&
    //             allListedNftsByListingId[i].isStaked == false
    //         ) {
    //             listedButNotStakedYet[
    //                 _userListingCount.current()
    //             ] = allListedNftsByListingId[i];
    //         }
    //         _userListingCount.increment();
    //     }
    //     return listedButNotStakedYet;
    // }

    // function getStakedNftsByUser() external returns (listing[] memory) {
    //     listing[] memory listedAndStaked;
    //     _userStakingCount.reset();
    //     for (uint256 i = 0; i < _listingId.current(); i++) {
    //         if (
    //             allListedNftsByListingId[i].listerAddress == msg.sender &&
    //             allListedNftsByListingId[i].isStaked == true
    //         ) {
    //             listedAndStaked[
    //                 _userStakingCount.current()
    //             ] = allListedNftsByListingId[i];
    //         }
    //         _userStakingCount.increment();
    //     }
    //     return listedAndStaked;
    // }
}
