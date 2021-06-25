// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/NV_IPortfolioFactory.sol";
import "./NV_Portfolio.sol";

contract NV_PortfolioFactory is NV_IPortfolioFactory {
  address public admin;


  constructor() {
    admin = msg.sender;
  }

  function createPortfolio(uint8 _riskTolerance) external override returns(address) {
    require(msg.sender == admin, "Wrong caller");

    address portfolioAddr = address(new NV_Portfolio(_riskTolerance, admin));
    return portfolioAddr;
  }
}
