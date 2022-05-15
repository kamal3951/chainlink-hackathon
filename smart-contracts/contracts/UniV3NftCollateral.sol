//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "./UtilityToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error Staking__TransferFailed();

contract UniV3NftCollateral {
    //Token allowed to stake
    IERC721 public stakingTokens;

    //all users
    address[] AllUsers;

    //Total worth of supplied nfts
    uint256 public totalTokenSupplyWorth;

    //mapping of user to a mapping of tokenIds owned by the user
    mapping(address => uint256[]) NftsLendedByUser;

    constructor() {
        stakingToken = IERC721("0xC36442b4a4522E871399CD717aBDD847Ab11FE88");
    }

    function stake(uint256 tokenId) external returns (bool) {
        if (NftsLendedByUser[msg.sender].length == 0) {
            AllUser.push(msg.sender);
        }
        NftsLendedByUser[msg.sender].push(tokenId);
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
}
