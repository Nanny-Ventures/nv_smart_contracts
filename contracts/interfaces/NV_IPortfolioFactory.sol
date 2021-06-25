// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface NV_IPortfolioFactory {
  function createPortfolio(uint8 _riskTolerance) external returns(address);
}
