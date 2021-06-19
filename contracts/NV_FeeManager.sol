// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";

contract NV_FeeManager is Ownable {
  uint8 public withdrawalFeePercentage; //  success fee
  uint8 public withdrawalFeePercentageUrgent; //  withdrawal when not in withdrawal period


  event FreeWithdrawalAllowed(bool _allowed);


  /**
   * @dev Updates withdrawalFeePercentage.
   * @param _feePercentage Percentage to use.
   */
  function updateWithdrawalFeePercentage(uint8 _feePercentage) external onlyOwner {
    withdrawalFeePercentage = _feePercentage;
  }

  /**
   * @dev Updates withdrawalFeePercentageUrgent.
   * @param _feePercentage Percentage to use.
   */
  function updateWithdrawalFeePercentageUrgent(uint8 _feePercentage) external onlyOwner {
    withdrawalFeePercentageUrgent = _feePercentage;
  }
}
