// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// import "./NV_Portfolio.sol";
// import "./NV_FeeManager.sol";
// import "./NV_InvestorManager.sol";

contract NV_Admin is Ownable, Pausable {
  // address public feeManager;

  mapping(address => bool) public isTrader;

  // event Enrolled(address _investor, address trader);
  // event Unenrolled(address _investor, address trader);
  

  /**
   * @dev Makes address as a trader.
   * @param _make Whether make a trader or removes.
   * @param _trader Trader Address.
   */
  function makeTrader(bool _make, address _trader) external onlyOwner {
    isTrader[_trader] = _make;
  }

  // /**
  //  * @dev Updates FeeManager address.
  //  * @param _manager Manager address.
  //  */
  // function updateFeeManager(address _manager) external onlyOwner {
  //   require(_manager != address(0), "Wrong manager");

  //   feeManager = _manager;
  // }
}
