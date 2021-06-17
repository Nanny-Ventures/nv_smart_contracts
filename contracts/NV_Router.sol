// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NV_Router {
  string public constant name = "";
  address public constant dexAddress = address(0);

  /**
   * @dev Processes trade.
   * @param _assetFrom Asset to be exchanged from.
   * @param _assetFromAmount AssetFrom amount to be traded.
   * @param _assetTo Asset to be exchanged to.
   * @param _slippage Slippage value.
   */
  function trade(address _assetFrom, uint256 _assetFromAmount, address _assetTo, uint8 _slippage) external {
    //  TODO:
    // dexAddress.swap(_assetFrom, _assetFromAmount, _assetTo, slippage, etc);
    // _assetFrom.transfer(msg.sender, _assetFrom.balance(this));
  }
}
