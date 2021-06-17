// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./NV_Admin.sol";
import "./NV_Router.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NV_Portfolio is Ownable {
  uint256 constant MAX_INT = (2**256) - 1;

  uint8 public riskTolerance; //  low, mid, high
  address public admin;

  address[] public assetsOwned;
  mapping (address => uint256) private assetIdx;


  event Trade(address indexed _assetFrom, uint256 _assetFromAmount, address indexed _assetTo, address indexed _routerUniAddr);


  constructor(uint8 _riskTolerance, address _admin) {
    require(_riskTolerance < 3, "Wrong type");
    require(_admin != address(0), "Wrong admin");
    
    riskTolerance = _riskTolerance;
    admin = _admin;
  }

  /**
   * @dev Gets all assets owned by portfolio.
   * @return All assets owned by portfolio.
   */
  function getAssetsOwned() external view returns(address[] memory) {
    return assetsOwned;
  }

  /**
   * @dev Performs trade with defined amount.
   * @param _assetFrom Asset address to sell.
   * @param _assetFromAmount Amount of _assetFrom to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function tradeAmount(uint8 _slippage, address _assetFrom, uint256 _assetFromAmount, address _assetTo, address _router) public {
    require(NV_Admin(admin).isTrader(msg.sender), "Not trader");
    require(_assetFromAmount > 0, "Wrong _assetFromAmount");
    require(_assetTo != address(0), "Wrong _assetTo");
    require(_router != address(0), "Wrong _router");
    require(NV_Admin(admin).isStableAllowed(_assetFrom) || NV_Admin(admin).isStableAllowed(_assetTo), "No stable");

    uint256 _assetFromBalance = IERC20(_assetFrom).balanceOf(address(this));
    require(_assetFromBalance >= _assetFromAmount, "_assetFrom not owned");

    if (IERC20(_assetFrom).allowance(address(this), _router) == 0) {
      IERC20(_assetFrom).approve(_router, MAX_INT);
    }

    NV_Router(_router).trade(_assetFrom, _assetFromAmount, _assetTo, _slippage);
    
    if (!isAssetOwned(_assetTo)) {
      addOwnedAsset(_assetTo);
    }

    if (IERC20(_assetFrom).balanceOf(address(this)) == 0) {
      removeOwnedAsset(_assetFrom);
    }

    emit Trade(_assetFrom, _assetFromAmount, _assetTo, _router);
  }

  /**
   * @dev Performs trade with defined amount.
   * @param _assetFrom Asset address to sell.
   * @param _assetFromPercentage Percentage of _assetFrom to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function tradePercentage(uint8 _slippage, address _assetFrom, uint8 _assetFromPercentage, address _assetTo, address _router) external {
    uint256 _assetFromBalance = IERC20(_assetFrom).balanceOf(address(this));
    require(_assetFromBalance > 0, "_assetFrom not owned");

    tradeAmount(_slippage, _assetFrom, (_assetFromBalance * 100) / _assetFromPercentage, _assetTo, _router);
  }

  /**
   * @dev Sells all owned assets.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function sellAllAssets(uint8 _slippage, address _assetTo, address _router) external {
    require(msg.sender == admin || NV_Admin(admin).isTrader(msg.sender), "Not allowed");

    uint256 assetsLength = assetsOwned.length;

    for (uint256 i = 0; i < assetsLength; i ++) {
      uint256 _assetFromBalance = IERC20(assetsOwned[i]).balanceOf(address(this));
      tradeAmount(_slippage, assetsOwned[i], _assetFromBalance, _assetTo, _router);
    }
  }

  /**
   * @dev Withdraws profit.
   * @param _percentageToWithdraw Percentage of profit to withdraw.
   * @param _stableAsset Asset (stable coin) to be used for profit withdrawal.
   * @param _addressTo Address profit should be sent to. msg.sender will used if 0x0.
   */
  function withdrawProfit(uint8 _percentageToWithdraw, address _stableAsset, address _addressTo) external {
    // require(tradablePeriodFinished, “No allowed“);
    // require(trader != investor, “Deleted acc”);
    // require(feeManager.isAssetAllowed(_baseCurrency), “Wrong base token”)

    // 0. _baseToken.balanceOf(this) * _percentageToWithdraw;
    // 1. calculate fees;
    // 2. transfer fee to feeManager;
    // 3. transfer profit to _addressTo;
  }


  /**
   * HELPERS
   */

  /**
   * @dev Checks if this portfolio owns asset.
   * @param _asset Asset address.
   * @return Whether owns or not.
   */
  function isAssetOwned(address _asset) private view returns(bool) {
    return assetsOwned[assetIdx[_asset]] == _asset;
  }

  /**
   * @dev Adds asset to the assetsOwned.
   * @param _asset Asset address.
   */
  function addOwnedAsset(address _asset) private {
    assetIdx[_asset] = assetsOwned.length;
  }

  /**
   * @dev Removes asset from the assetsOwned.
   * @param _asset Asset address.
   */
  function removeOwnedAsset(address _asset) private {
    uint256 idxToDelete = assetIdx[_asset];

    if (idxToDelete == assetsOwned.length - 1) {
      assetsOwned.pop();
      delete assetIdx[_asset];
    } else {
      address lastAsset = assetsOwned[assetsOwned.length - 1];
      assetIdx[lastAsset] = idxToDelete;
      assetsOwned[idxToDelete] = lastAsset;
      assetsOwned.pop();
    }
  }
  
}
