//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract UtilityTokenERC721 is ERC721 {
    constructor() ERC721("UniLoanTokenSEC721", "ULTERC721") {}
}
