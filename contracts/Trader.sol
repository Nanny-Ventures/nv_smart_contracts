// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Trader {
  address public investor;
  address public trader;
  address public feeManager;

  uint256 constant MAX_INT = (2**256) - 1;

    
  constructor(address _investor, address _trader, address _feeManager) {
    require(_investor != address(0), "Wrong investor");
    require(_trader != address(0), "Wrong _trader");
    require(_feeManager != address(0), "Wrong _feeManager");
  }
}
