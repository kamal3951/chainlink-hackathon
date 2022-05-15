//SPDX-License-Identifier:MIT
pragma solidity >0.8.4;

import "./UtilityToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__TransferFailed();

contract UniV3NftCollateral {
    //Token allowed to stake
    IERC721 public stakingTokens;
    //ERC20 allowed to lend
    IERC20 public lendingMoney;

    //all stakers
    address[] AllStakers;
    //all lenders
    address[] AllLenders;

    //Total worth of supplied nfts
    uint256 public totalTokenSupplyWorth;
    //Total supplied money
    uint256 public totalSupplyMoney;
    //money used for loan
    uint256 public totalLoanMoney;

    //mapping of staker to a mapping of tokenIds owned by the user
    mapping(address => uint256[]) NftsStakedByUser;
    //mapping of lender to lended amount
    mapping(address => mappping(uin256 => uint256)) MoneyLendedByUser;

    constructor() {
        stakingToken = IERC721("0xC36442b4a4522E871399CD717aBDD847Ab11FE88");
        lendingMoney = IERC20("RINKEBY-ETH-ADDRESS");
    }

    function lendMoney(uint256 tokenId, uint256 amount)
        external
        returns (bool)
    {
        AllLenders.push(msg.sender);
        MoneyLendedByUser[msg.sender] += amount;
        totalSupplyMoney += amount;
        bool success = lendingMoney.transferFrom(
            msg.sender,
            address(this),
            amount
        );
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function withdrawMoney(uint256 amount) external returns (bool) {
        require(amount <= MoneyLendedByUser[msg.sender]);
        MoneyLendedByUser[msg.sender] -= amount;
        bool success = lendingMoney.transfer(msg.sender, amount);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function stakeNft(uint256 tokenId) external returns (bool) {
        if (NftsStakedByUser[msg.sender].length == 0) {
            AllStakers.push(msg.sender);
        }
        NftsStakedByUser[msg.sender].push(tokenId);
        bool success = stakingTokens[tokenId].safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        totalTokenSupplyWorth += uint256(stakingTokens[tokenId].liquidity);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function withdrawNft(uint256 tokenId) external returns (bool) {
        if (NftLendedByUser[msg.sender].length == 1) {
            NftsLendedByUser[msg.sender][tokenId].pop();
            AllLenders[msg.sender].pop();
        }
        NftsLendedByUser[msg.sender][tokenId].pop();
        bool success = stakingToken[tokenId].safeTransfer(msg.sender, tokenId);
        totalTokenSupplyWorth -= uint256(stakingTokens[tokenId].liquidity);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function claimInterestOverLending() external returns (bool) {}
}
