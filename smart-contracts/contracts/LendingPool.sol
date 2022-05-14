//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./UtilityToken.sol";

contract LendingPool {
    using SafeMath for uint256;

    UtilityToken ULT;

    struct reserve {
        uint256 totalReserve;
        uint256 lendedReserve;
        uint256 idleReserve;
    }

    function deposit(address asset, uint256 amount) external returns (bool) {}
}
