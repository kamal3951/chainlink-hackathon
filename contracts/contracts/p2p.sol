// //SPDX-License-Identifier:MIT
// pragma solidity >=0.7.6;
// pragma abicoder v2;

// import "@openzeppelin/contracts/utils/Counters.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Enumerable.sol";

// import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

// // import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// //error p2p__TransferFailed();

// contract p2p {
//     using Counters for Counters.Counter;
//     Counters.Counter private _ourContractTokenId;
//     Counters.Counter private _listedItems;
//     Counters.Counter private _stakedItems;

//     Counters.Counter _userLoanCount;
//     Counters.Counter _userListingCount;
//     Counters.Counter _userStakingCount;
//     Counters.Counter _allNftsAvailableToBeStakedCount;

//     //Token allowed to stake
//     INonfungiblePositionManager public immutable listingToken;
//     //ERC20 allowed to lend
//     IERC20 public immutable lendingMoney;

//     //struct listing
//     struct listing {
//         address listerAddress;
//         uint256 tokenIdListed;
//         uint256 LoanAmount;
//         uint256 LoanTimePeriod;
//         uint256 ourContractTokenId;
//         bool isStaked;
//         address currentOwner;
//         address stakedTo;
//     }

//     mapping(uint256 => listing) allListedNftsByTokenId;

//     //Total worth of supplied nfts
//     uint256 public totalTokenSupplyWorth;

//     //money used for loan
//     uint256 public totalLoanMoney;

//     constructor(address _listingTokenAddress) {
//         listingToken = INonfungiblePositionManager(_listingTokenAddress);
//         //UniswapV3 Rinkeby Adddress 0xC36442b4a4522E871399CD717aBDD847Ab11FE88
//         lendingMoney = IERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);
//         //Rinkeby DAI Address
//     }

//     // event ListNft(uint256 tokenId, uint256 LoanAmount, uint256 LoanTimePeriod);
//     // event LendMoney(listing Listing);

//     function listNft(
//         uint256 tokenId,
//         uint256 LoanAmount,
//         uint256 LoanTimePeriod
//     ) external {
//         // _ourContractTokenId.increment();
//         // _listedItems.increment();
//         // uint256 ourContractTokenId = _ourContractTokenId.current();

//         //fetch the liquidity and set amount < 0.5 * liquidity
//         // uint256 NftLiquidity;
//         // (, , , , , , , NftLiquidity, , , , ) = listingToken.positions(tokenId);
//         // require(
//         //     LoanAmount < NftLiquidity / 2,
//         //     "You can not get loan of more than 50% worth of your position's liquidity"
//         // );
//         // listing memory Listing = listing(
//         //     msg.sender,
//         //     tokenId,
//         //     LoanAmount,
//         //     LoanTimePeriod,
//         //     ourContractTokenId,
//         //     false,
//         //     msg.sender,
//         //     address(0)
//         // );
//         listingToken.safeTransferFrom(msg.sender, address(this), tokenId);
//         //.push
//         // allListedNftsByTokenId[ourContractTokenId] = Listing;

//         // totalTokenSupplyWorth += uint256(NftLiquidity);

//         // emit ListNft(tokenId, LoanAmount, LoanTimePeriod);
//     }

//     function lendMoney(listing memory Listing) external returns (bool) {
//         Listing.currentOwner = address(this);
//         Listing.stakedTo = msg.sender;
//         _stakedItems.increment();

//         totalLoanMoney += Listing.LoanAmount;

//         bool success = lendingMoney.transferFrom(
//             msg.sender,
//             Listing.listerAddress,
//             Listing.LoanAmount
//         );

//         Listing.isStaked = true;
//         return success;

//         // emit LendMoney(Listing);
//     }

//     function getLoansDispersedByUser() external returns (listing[] memory) {
//         listing[] memory ListingThatIsLended;
//         _userLoanCount.reset();
//         for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
//             if (allListedNftsByTokenId[i].stakedTo == msg.sender) {
//                 ListingThatIsLended[
//                     _userLoanCount.current()
//                 ] = allListedNftsByTokenId[i];
//             }
//             _userLoanCount.increment();
//         }
//         return ListingThatIsLended;
//     }

//     function getListedNftsByUser() external returns (listing[] memory) {
//         listing[] memory listedButNotStakedYet;
//         _userListingCount.reset();
//         for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
//             if (
//                 allListedNftsByTokenId[i].listerAddress == msg.sender &&
//                 allListedNftsByTokenId[i].isStaked == false
//             ) {
//                 listedButNotStakedYet[
//                     _userListingCount.current()
//                 ] = allListedNftsByTokenId[i];
//             }
//             _userListingCount.increment();
//         }
//         return listedButNotStakedYet;
//     }

//     function getStakedNftsByUser() external returns (listing[] memory) {
//         listing[] memory listedAndStaked;
//         _userStakingCount.reset();
//         for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
//             if (
//                 allListedNftsByTokenId[i].listerAddress == msg.sender &&
//                 allListedNftsByTokenId[i].isStaked == true
//             ) {
//                 listedAndStaked[
//                     _userStakingCount.current()
//                 ] = allListedNftsByTokenId[i];
//             }
//             _userStakingCount.increment();
//         }
//         return listedAndStaked;
//     }

//     //MAKE THIS FUNCTION TO AS REPAY-LOAN
//     function getAllNftsListedAvailableToBeStaked()
//         external
//         returns (listing[] memory)
//     {
//         listing[] memory AllNftsListedAvailableToBeStaked;
//         _allNftsAvailableToBeStakedCount.reset();
//         for (uint256 i = 0; i < _ourContractTokenId.current(); i++) {
//             if (allListedNftsByTokenId[i].isStaked == false) {
//                 AllNftsListedAvailableToBeStaked[
//                     _allNftsAvailableToBeStakedCount.current()
//                 ] = allListedNftsByTokenId[i];
//             }
//         }
//         return AllNftsListedAvailableToBeStaked;
//     }

//     //function claimInterestOverLending() external returns (bool) {}
// }
