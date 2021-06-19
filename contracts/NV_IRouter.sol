// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

interface NV_IRouter {
  /**
   * @dev Processes trade.
   * @param _assetFrom Asset to be exchanged from.
   * @param _assetFromAmount AssetFrom amount to be traded.
   * @param _assetTo Asset to be exchanged to.
   * @param _slippage Slippage value.
   */
  function trade(address _assetFrom, uint256 _assetFromAmount, address _assetTo, uint8 _slippage) external;
}
