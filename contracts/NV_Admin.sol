// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./NV_FeeManager.sol";
import "./NV_PortfolioManager.sol";


contract NV_Admin is NV_FeeManager, NV_PortfolioManager {
  address public devFeeDistributionManager;

  mapping(address => bool) public isTrader;

  event TraderUpdated(bool _make, address _trader);


  constructor(address _devFeeDistributionManager, address _portfolioFactory) {
    devFeeDistributionManager = _devFeeDistributionManager;
    portfolioFactory = _portfolioFactory;
  }

  /**
   * @dev Updates address as a trader.
   * @param _make Whether make a trader or removes.
   * @param _trader Trader Address.
   */
  function updateTrader(bool _make, address _trader) external onlyOwner {
    isTrader[_trader] = _make;
    emit TraderUpdated(_make, _trader);
  }

  /**
   * @dev Updates devFeeDistributionManager.
   * @param _addr Address to be set.
   */
  function updateDevFeeDistributionManager(address _addr) external onlyOwner {
    require(_addr != address(0), "Wrong addr");
    devFeeDistributionManager = _addr;
  }

  /**
   * @dev Updates portfolioFactory.
   * @param _addr Address to be set.
   */
  function updatePortfolioFactory(address _addr) external onlyOwner {
    require(_addr != address(0), "Wrong addr");
    portfolioFactory = _addr;
  }
}
