// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol";

contract LiquidityExamples is IERC721Receiver, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _listingId;
    Counters.Counter private _listedItems;
    Counters.Counter private _stakedItems;

    Counters.Counter _userLoanCount;
    Counters.Counter _userListingCount;
    Counters.Counter _userStakingCount;
    Counters.Counter _allNftsAvailableToBeStakedCount;

    address public constant DAI = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    address public constant ETH = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;

    uint24 public constant poolFee = 3000;

    address payable owner;

    //Token allowed to stake - UniswapV3 LP Token
    INonfungiblePositionManager public immutable listingToken;
    //ERC20 allowed to lend
    IERC20 public immutable lendingMoney;

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

    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    /// @dev deposits[tokenId] => Deposit
    mapping(uint256 => Deposit) public deposits;
    mapping(address => address) public borrowerToLender;
    mapping(address => uint128) public borrowerToLiquidity;
    mapping(address => uint256) public borrowerToTokenId;

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

        //fetch the liquidity and set amount <  liquidity/2
        (, , , , , , ,uint128 NftLiquidity, , , , ) = listingToken.positions(tokenId);
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

    // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // get position information

        _createDeposit(operator, tokenId);

        return this.onERC721Received.selector;
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

    function _createDeposit(address owner, uint256 tokenId) internal {
        (
            ,
            ,
            address token0,
            address token1,
            ,
            ,
            ,
            uint128 liquidity,
            ,
            ,
            ,

        ) = nonfungiblePositionManager.positions(tokenId);

        // set the owner and data for position
        // operator is msg.sender
        deposits[tokenId] = Deposit({
            liquidity,
            owner,
            token0,
            token1
        });
    }

    function findPosition(uint256 id)
        external
        view
        returns (address owner, uint128 liquidity)
    {
        (, , , , , , , liquidity, , , , ) = nonfungiblePositionManager
            .positions(id);
    }

    /// @notice Collects the fees associated with provided liquidity
    /// @dev The contract must hold the erc721 token before it can collect fees
    /// @param tokenId The id of the erc721 token
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collectAllFees(uint256 tokenId)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        // Caller must own the ERC721 position
        // Call to safeTransfer will trigger `onERC721Received` which must return the selector else transfer will fail
        nonfungiblePositionManager.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        // set amount0Max and amount1Max to uint256.max to collect all fees
        // alternatively can set recipient to msg.sender and avoid another transaction in `sendToOwner`
        INonfungiblePositionManager.CollectParams
            memory params = INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: msg.sender,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);
        // TransferHelper.safeTransfer(DAI, address(this), amount0);
        // TransferHelper.safeTransfer(ETH, address(this), amount1);
        // send collected feed back to owner
        _sendToOwner(tokenId, amount0, amount1);
    }

    /// @notice Transfers funds to owner of NFT
    /// @param tokenId The id of the erc721
    /// @param amount0 The amount of token0
    /// @param amount1 The amount of token1
    function _sendToOwner(
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    ) internal {
        // get owner of contract
        address owner = msg.sender;

        address token0 = DAI;
        address token1 = ETH;
        // send collected fees to owner
        // TransferHelper.safeTransfer(token0, borrowerToLender[], amount0 / 2);
        // TransferHelper.safeTransfer(token1, borrowerToLender[], amount1 / 2);
    }

    function settleLoan(address borrower) public payable {
        require(borrower == msg.sender);
        uint128 loanAmt = borrowerToLiquidity[borrower];
        TransferHelper.safeTransfer(DAI, borrowerToLender[borrower], loanAmt);

        //collectAllFees(borrowerToTokenId[borrower]);
    }




    //Getter functions
    function getListedNftsByUser() external returns (listing[] memory) {
        listing[] memory listedButNotStakedYet;
        _userListingCount.reset();
        for (uint256 i = 0; i < _listingId.current(); i++) {
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
        for (uint256 i = 0; i < _listingId.current(); i++) {
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
        for (uint256 i = 0; i < _listingId.current(); i++) {
            if (allListedNftsByTokenId[i].isStaked == false) {
                AllNftsListedAvailableToBeStaked[
                    _allNftsAvailableToBeStakedCount.current()
                ] = allListedNftsByTokenId[i];
            }
        }
        return AllNftsListedAvailableToBeStaked;
    }
}
