// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

// import "@openzeppelin/contracts/access/Ownable.sol";

contract NV_FeeManager {
  // bool public freeWithdrawalAllowed;

  // uint8 public withdrawalFeePercentage; //  success fee
  // uint8 public withdrawalFeePercentageUrgent; //  withdrawal during trade period

  // uint256 public tradePeriodDuration;
  // uint256 public tradePeriodStartedAt;

  // mapping (address => bool) public stableAllowed;
  // address[] public allowedStables;


  // event TradePeriodStarted(uint256 startedAt);


  // constructor(uint8 _withdrawalFeePercentage, uint8 _withdrawalFeePercentageUrgent) {
  //   withdrawalFeePercentage = _withdrawalFeePercentage;
  //   withdrawalFeePercentageUrgent = _withdrawalFeePercentageUrgent;
  // }


  // /**
  //  * @dev Allows or disallows commission free withdraw.
  //  * @param _allowed Alowed or not.
  //  */
  // function updateFreeWithdrawAllowed(bool _allowed) external onlyOwner {
  //   freeWithdrawalAllowed = _allowed;
  // }

  // /**
  //  * @dev Updates trade period.
  //  * @param _duration Duration value.
  //  */
  // function updateTradePeriodDuration(uint256 _duration) external onlyOwner {
  //   tradePeriodDuration = _duration;
  // }

  // /**
  //  * @dev Starts trade period.
  //  */
  // function startTradePeriod() external onlyOwner {
  //   tradePeriodStartedAt = block.timestamp;

  //   emit TradePeriodStarted(tradePeriodStartedAt);
  // }

  // /**
  //  * TODO:
  //  *  is needed?
  //  *  just decreasing?
  //  *  DAOn holders some benefits?
  //  */
  // function updateWithdrawalFeePercentage(uint8 _feePerc) external onlyOwner {
  //   withdrawalFeePercentage = _feePerc;
  // }

  // function updateWithdrawalFeePercentageUrgent(uint8 _feePerc) external onlyOwner {
  //   withdrawalFeePercentageUrgent = _feePerc;
  // }
}
