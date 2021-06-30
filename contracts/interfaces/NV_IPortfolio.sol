// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface NV_IPortfolio {
  /**
   * @dev Converts stables.
   * @param _slippage Slippage value.
   * @param _assetFrom Asset address to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   */
  function convertStables(uint8 _slippage, address _assetFrom, address _assetTo, address _router) external;

  /**
   * @dev Sells all owned assets.
   * @param _delete Whether delete portfolio or not.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function sellAllAssets(bool _delete, uint8 _slippage, address _assetTo, address _router) external;

  /**
   * @dev Withdraws balance.
   * @param _percentageToWithdraw Percentage of balance to withdraw.
   * @param _assetTo Asset (stable coin) to be used for balance withdrawal.
   * @param _addressTo Receiver address. msg.sender will used if 0x0.
   */
  function withdrawBalance(uint8 _percentageToWithdraw, address _assetTo, address _addressTo) external;
}
