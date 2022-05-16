//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UtilityTokenERC20 is ERC20 {
    constructor() ERC20("UniLoanTokenERC20", "ULTERC20") {
        _mint(msg.sender, 100000 * 10**18);
    }
}
