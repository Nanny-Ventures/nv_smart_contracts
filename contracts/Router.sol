// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Router is Ownable {
  string public name;
  uint8 public slippage;
  address public contractAddress;


  /**
    * @dev Creates the Smart Contract.
    * @param _name Name of the DEX to be used.
    * @param _slippage Slippage to be used.
    * @param _contractAddress DEX address to be used.
   */
  constructor(string memory _name, uint8 _slippage, address _contractAddress) {
    require(bytes(_name).length > 0, "Wrong name");
    require(_slippage > 0, "Wrong slippage");
    require(_contractAddress != address(0), "Wrong _contractAddress");

    name = _name;
    slippage = _slippage;
    contractAddress = _contractAddress;
  }

  /**
   * @dev Processes trade.
   * @param _assetFrom Asset to be exchanged from.
   * @param _assetFromAmount AssetFrom amount to be traded.
   * @param _assetTo Asset to be exchanged to.
   */
  function trade(address _assetFrom, uint256 _assetFromAmount, address _assetTo) external {
    //  TODO:
    // contractAddress.swap(_assetFrom, _assetFromAmount, _assetTo, slippage, etc);
    // _assetFrom.transfer(msg.sender, _assetFrom.balance(this));
  }

  /**
   * @dev Updates max allowed slippage value.
   * @param _slippage Slippage to be used.
   */
  function updateSlippage(uint8 _slippage) external onlyOwner {
    require(_slippage > 0, "Wrong slippage");
    
    slippage = _slippage;
  }
}
