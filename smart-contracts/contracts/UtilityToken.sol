//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UtilityToken is ERC20 {
    constructor() ERC20("UniLoanToken", "ULT") {
        _mint(msg.sender, 1000 * 10**18);
    }
}
