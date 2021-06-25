// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface NV_IPortfolioFactory {
  /**
   * @dev Deploys new portfolio Smart Contract.
   * @param _riskTolerance Risk tolerance of the portfolio.
   * @return Deployed portfolio address.
   */
  function createPortfolio(uint8 _riskTolerance) external returns(address);
}
