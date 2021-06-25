// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface NV_IRouter {
  /**
   * @dev Processes trade.
   * @param _slippage Slippage value.
   * @param _assetFrom Asset to be exchanged from.
   * @param _assetFromAmount AssetFrom amount to be traded.
   * @param _assetTo Asset to be exchanged to.
   */
  function trade(uint8 _slippage, address _assetFrom, uint256 _assetFromAmount, address _assetTo) external;
}
