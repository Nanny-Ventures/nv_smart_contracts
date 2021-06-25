// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface NV_IPortfolio {
  function sellAllAssets(uint8 _slippage, address _assetTo, address _router) external;
  function withdrawBalance(uint8 _percentageToWithdraw, address _assetTo, address _addressTo) external;
}
