// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./Trader.sol";
import "./FeeManager.sol";

contract Admin is Ownable, Pausable {
  bool public freeWithdrawAllowed;

  address public feeManager;

  address[] traderContracts;
  mapping(address => uint256) public traderContractIdx;
  mapping(address => address) public traderContractForInvestor;


  event Enrolled(address _investor, address trader);
  

  constructor(address _feeManager) {
      feeManager = _feeManager;
  }

  
  /**
   * @dev Enrolls investor into the system.
   */
  function enroll() external whenNotPaused() {
    require(traderContractForInvestor[msg.sender] == address(0), "Investor enrolled");
    
    address trader = address(new Trader(msg.sender, owner(), feeManager));
    traderContractForInvestor[msg.sender] = trader;
    traderContractIdx[trader] = traderContracts.length;
    traderContracts.push(trader);

    emit Enrolled(msg.sender, trader);
  }

  /**
   * @dev Allows or disallows commission free withdraw.
   * @param _allowed Alowed or not.
   */
  function updateFreeWithdrawAllowed(bool _allowed) external onlyOwner {
    freeWithdrawAllowed = _allowed;
  }

  /**
   * @dev Deletes investor from the system.
   * @param _router Router address to be used.
   * @param _assetTo Asset address to be exchanged to.
   * @param _investorTo Address, that should receive ongoing profit after all fees.
   */
  function deleteInvestor(address _router, address _assetTo, address _investorTo) external {
    address trader = traderContractForInvestor[msg.sender];
    require(trader != address(0), "Investor not enrolled");

    delete traderContractForInvestor[msg.sender];

    //  TODO: invetorsSC.deleteInvestor(_routerUniAddr, _assetTo, _investorTo);

    uint256 idxToDelete = traderContractIdx[trader];

    if (idxToDelete == traderContracts.length - 1) {
      traderContracts.pop();
      delete traderContractIdx[trader];
    } else {
      address lastTrader = traderContracts[traderContracts.length - 1];
      traderContracts.pop();
      traderContractIdx[lastTrader] = idxToDelete;
      traderContracts[idxToDelete] = lastTrader;
    }
  }

  function updateFeeManager(address _feeManager) external onlyOwner {
    require(_feeManager != address(0), "Wrong feeManager");

    feeManager = _feeManager;
  }
}
