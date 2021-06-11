// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Trader {
    address public investor;
    address public trader;
    address public feeManager;
    
  constructor(address _investor, address _trader, address _feeManager) {
    require(_investor != address(0), "Wrong investor");
    require(_trader != address(0), "Wrong _trader");
    require(_feeManager != address(0), "Wrong _feeManager");
  }
}
