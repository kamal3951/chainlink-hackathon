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
import "@chainlink/contracts/src/v0.7/interfaces/AggregatorV3Interface.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

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
    address public constant USDC = 0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b;

    //Token allowed to stake
    INonfungiblePositionManager public constant listingToken =
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    //ERC20 allowed to lend
    IERC20 public immutable lendingMoney = IERC20(USDC);

    AggregatorV3Interface internal priceFeed =
        AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);

    function getLoanInUsd(uint256 tokenId) public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        (, , , , , , , uint128 NftLiquidity, , , , ) = listingToken.positions(
            tokenId
        );

        uint256 NftLoanInUsd = (uint256(NftLiquidity) * uint256(price)) /
            10**18;
        return NftLoanInUsd / 2;
    }

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
            getLoanInUsd(tokenId),
            LoanTimePeriod,
            _listingId.current(),
            false
        );

        totalTokenSupplyWorth += uint256(NftLiquidity);
        tokenIdToListingId[tokenId] = _listingId.current();

        borrowerToLender[borrower] = address(0);
        borrowerToLiquidity[borrower] = NftLiquidity;
        borrowerToTokenId[borrower] = tokenId;
        tokenIdToBorrower[tokenId] = borrower;
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
            lender != _listing.listerAddress,
            "Seller can not buy its own tokens"
        );

        _listing.isStaked = true;

        bool success = lendingMoney.transferFrom(
            lender,
            _listing.listerAddress,
            allListedNftsByListingId[listingId].LoanAmount
        );

        borrowerToLender[_listing.listerAddress] = lender;

        return success;
    }

    /// @notice Collects the fees associated with provided liquidity
    /// @dev The contract must hold the erc721 token before it can collect fees
    /// @param tokenId The id of the erc721 token
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collectFees(uint256 tokenId)
        internal
        returns (uint256 amount0, uint256 amount1)
    {
        listingToken.safeTransferFrom(msg.sender, address(this), tokenId);

        INonfungiblePositionManager.CollectParams
            memory params = INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: msg.sender,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });

        (amount0, amount1) = listingToken.collect(params);

        _sendToLender(tokenId, amount0, amount1);
    }

    /// @notice Transfers funds to owner of NFT
    /// @param tokenId The id of the erc721
    /// @param amount0 The amount of token0
    /// @param amount1 The amount of token1
    function _sendToLender(
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    ) internal {
        (, , address token0, address token1, , , , , , , , ) = listingToken
            .positions(tokenId);

        address borrower = tokenIdToBorrower[tokenId];
        TransferHelper.safeTransfer(
            token0,
            borrowerToLender[borrower],
            amount0 / 2
        );
        TransferHelper.safeTransfer(
            token1,
            borrowerToLender[borrower],
            amount1 / 2
        );
    }

    function repayLoan(address borrower) public payable {
        require(borrower == msg.sender);
        lendingMoney.transferFrom(
            borrower,
            borrowerToLender[borrower],
            getLoanInUsd(borrowerToTokenId[borrower])
        );
        listingToken.safeTransferFrom(
            address(this),
            borrower,
            borrowerToTokenId[borrower]
        );
        collectFees(borrowerToTokenId[borrower]);
    }
}
