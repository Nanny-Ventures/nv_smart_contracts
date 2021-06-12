// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./Trader.sol";
import "./FeeManager.sol";

contract Admin is Ownable, Pausable {
  address public feeManager;

  address[] traderContracts;
  mapping(address => uint256) public traderContractIdx;
  mapping(address => address) public traderContractForInvestor;


  event Enrolled(address _investor, address trader);
  event Unenrolled(address _investor, address trader);
  

  constructor(address _feeManager) {
    feeManager = _feeManager;
  }

  
  /**
   * @dev Enrolls investor into the system.
   */
  function enroll() external whenNotPaused() {
    require(traderContractForInvestor[msg.sender] == address(0), "Investor enrolled");
    
    address traderContract = address(new Trader(msg.sender, owner(), feeManager));
    traderContractForInvestor[msg.sender] = traderContract;
    traderContractIdx[traderContract] = traderContracts.length;
    traderContracts.push(traderContract);

    emit Enrolled(msg.sender, traderContract);
  }

  /**
   * @dev Deletes investor from the system.
   * @param _router Router address to be used.
   * @param _assetTo Asset address to be exchanged to.
   * @param _investorTo Address, that should receive ongoing profit after all fees.
   */
  function unenroll(address _router, address _assetTo, address _investorTo) external {
    address traderContract = traderContractForInvestor[msg.sender];
    require(traderContract != address(0), "Investor not enrolled");

    delete traderContractForInvestor[msg.sender];

    //  TODO: invetorsSC.deleteInvestor(_routerUniAddr, _assetTo, _investorTo);

    uint256 idxToDelete = traderContractIdx[traderContract];

    if (idxToDelete == traderContracts.length - 1) {
      traderContracts.pop();
      delete traderContractIdx[traderContract];
    } else {
      address lastTrader = traderContracts[traderContracts.length - 1];
      traderContracts.pop();
      traderContractIdx[lastTrader] = idxToDelete;
      traderContracts[idxToDelete] = lastTrader;
    }

    emit Unenrolled(msg.sender, traderContract);
  }

  /**
   * @dev Updates FeeManager address.
   * @param _feeManager FeeManager address.
   */
  function updateFeeManager(address _feeManager) external onlyOwner {
    require(_feeManager != address(0), "Wrong feeManager");

    feeManager = _feeManager;
  }
}
