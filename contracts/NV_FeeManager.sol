// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract NV_FeeManager is Ownable {
  uint8 public successFeePercentage;
  uint8 public urgentFeePercentage;

  uint256 public requestDuration;

  event FreeWithdrawalAllowed(bool _allowed);


  constructor () {
    requestDuration = 10 days;
  }


  /**
   * @dev Updates successFeePercentage.
   * @param _feePercentage Percentage to use.
   */
  function updateSuccessFeePercentage(uint8 _feePercentage) external onlyOwner {
    successFeePercentage = _feePercentage;
  }

  /**
   * @dev Updates urgentFeePercentage.
   * @param _feePercentage Percentage to use.
   */
  function updateUrgentFeePercentage(uint8 _feePercentage) external onlyOwner {
    urgentFeePercentage = _feePercentage;
  }

  /**
   * @dev Updates requestDuration.
   * @param _requestDuration Duration.
   */
  function updateRequestDuration(uint256 _requestDuration) external onlyOwner {
    requestDuration = _requestDuration;
  }
}
