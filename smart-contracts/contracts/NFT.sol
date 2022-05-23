//SPDX-License-Identifier:MIT
pragma solidity >=0.7.6;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

//THIS CONTRACT IS ONLY WRITTEN TO GET SOME NFTS IN OUR LOCAL HARDHAT NETOWRK ADDRESSES
// AND TEST OUT THE MARKETPLACE

contract NFT is ERC721 {
    constructor() ERC721("Dummy NFTS", "DN") {}

    using Counters for Counters.Counter;
    Counters.Counter private tokenID;

    function mint() public {
        uint256 tid = tokenID.current();
        _mint(msg.sender, tid);
        tokenID.increment();
    }
}
