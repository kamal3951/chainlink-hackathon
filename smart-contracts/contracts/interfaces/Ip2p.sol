//SPDX-License-Identifier:MIT
pragma solidity >0.8.4;

struct listing {
    address payable listerAddress;
    uint128 tokenIdListed;
    uint128 LoanAmount;
    uint256 LoanTimePeriod;
}

interface Ip2p {
    function listNft(
        uint256 tokenId,
        uint256 LoanAmount,
        uint256 LoanTimePeriod
    ) external returns (bool);

    function lendMoney(listing memory Listing) external returns (bool);
}
