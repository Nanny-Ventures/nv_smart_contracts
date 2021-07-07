// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";


contract NV_TradingFeeDepositor is Ownable {
  mapping(address => uint256) public deposits;

  event DepositETH(address _portfolio, uint256 _amount);

  /**
   * @dev Makes deposit.
   * @param _portfolio Portfolio address.
   */
  function depositETH(address _portfolio) external {
    require(_portfolio != address(0), "Wrong portfolio");
    require(msg.value > 0, "Wrong value");

    deposits[_portfolio] += msg.value;
    emit DepositETH(_portfolio, msg.value);
  }

  /**
   * @dev Withdraws eth balance.
   * @param _recipient Recipient address to receive eth.
   */
  function withdrawETH(address _recipient) external onlyOwner {
    require(_recipient != address(0), "Wrong recipient");

    _recipient.transfer(address(this).balance);
  }
}
