// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./NV_IRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NV_Router_1Inch is NV_IRouter {
  string public constant name = "1Inch";
  address public constant dexAddress = address(0);

  /**
   * @dev Processes trade.
   * @param _slippage Slippage value.
   * @param _assetFrom Asset to be exchanged from.
   * @param _assetFromAmount AssetFrom amount to be traded.
   * @param _assetTo Asset to be exchanged to.
   */
  function trade(uint8 _slippage, address _assetFrom, uint256 _assetFromAmount, address _assetTo) external override {
    //  TODO:
    // dexAddress.swap(_assetFrom, _assetFromAmount, _assetTo, slippage, etc);
    // _assetFrom.transfer(msg.sender, _assetFrom.balance(this));
  }
}
