// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./NV_Admin.sol";
import "./NV_Router.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NV_Portfolio is Ownable {
  uint256 constant MAX_INT = (2**256) - 1;

  uint8 public portfolioType;
  address public admin;
  uint256 public nftId;

  address[] assetsOwned;
  mapping (address => uint256) assetIdx;


  event Trade(address indexed _assetFrom, uint256 _assetFromAmount, address indexed _assetTo, address indexed _routerUniAddr);


  modifier onlyTrader() {
    require(NV_Admin(admin).isTrader(msg.sender), "Not trader");
    _;
  }

  modifier onlyInvestor() {
    require(IERC721(owner()).ownerOf(nftId) == msg.sender, "Not portfolio owner");
    _;
  }


  constructor(uint8 _type, address _admin, uint256 _nftId) {
    require(_type < 3, "Wrong type");
    require(_admin != address(0), "Wrong admin");
    
    portfolioType = _type;
    admin = _admin;
    nftId = _nftId;
  }

  /**
   * @dev Performs trade with defined amount.
   * @param _assetFrom Asset address to sell.
   * @param _assetFromAmount Amount of _assetFrom to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function tradeAmount(address _assetFrom, uint256 _assetFromAmount, address _assetTo, address _router, uint256 _slippage) public onlyTrader {
    require(_assetFrom != address(0), "Wrong _assetFrom");
    require(_assetTo != address(0), "Wrong _assetTo");
    require(_router != address(0), "Wrong _router");

    uint256 _assetFromBalance = IERC20(_assetFrom).balanceOf(address(this));
    require(_assetFromBalance > 0, "_assetFrom not owned");
    require(_assetFromAmount <= _assetFromBalance, "Wrong _assetFromAmount");

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
  function tradePercentage(address _assetFrom, uint8 _assetFromPercentage, address _assetTo, address _router, uint256 _slippage) external onlyTrader {
    uint256 _assetFromBalance = IERC20(_assetFrom).balanceOf(address(this));
    require(_assetFromBalance > 0, "_assetFrom not owned");

    tradeAmount(_assetFrom, (_assetFromBalance * 100) / _assetFromPercentage, _assetTo, _router, _slippage);
  }

  /**
   * @dev Sells all owned assets.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function sellAllAssets(address _assetTo, address _router, uint256 _slippage) external onlyTrader {
    uint256 assetsLength = assetsOwned.length;

    for (uint256 i = 0; i < assetsLength; i ++) {
      uint256 _assetFromBalance = IERC20(assetsOwned[i]).balanceOf(address(this));
      tradeAmount(assetsOwned[i], _assetFromBalance, _assetTo, _router, _slippage);
    }
  }

  /**
   * @dev Withdraws profit.
   * @param _percentageToWithdraw Percentage of profit to withdraw.
   * @param _stableAsset Asset (stable coin) to be used for profit withdrawal.
   * @param _addressTo Address profit should be sent to. msg.sender will used if 0x0.
   */
  function withdrawProfit(uint8 _percentageToWithdraw, address _stableAsset, address _addressTo) external onlyInvestor {
    // require(tradablePeriodFinished, “No allowed“);
    // require(trader != investor, “Deleted acc”);
    // require(feeManager.isAssetAllowed(_baseCurrency), “Wrong base token”)

    // 0. _baseToken.balanceOf(this) * _percentageToWithdraw;
    // 1. calculate fees;
    // 2. transfer fee to feeManager;
    // 3. transfer profit to _addressTo;
  }

  /**
   * @dev Sells all assets owned and deletes portfolio.
   * @param _router Router address.
   * @param _stableAsset Asset (stable coin) to be used for profit withdrawal.
   * @param _addressTo Address profit should be sent to. msg.sender will used if 0x0.
   */
  function deletePortfolio(address _router, address _stableAsset, address _addressTo) external onlyInvestor {
    // require(feeManager.allowedAssets[_assetTo], “Wrong _assetTo”);

    // forEach(assetsOwned -> assetFrom) {
    // 	uint256 balance = assetFrom.balance(address(this));
    // 	this,trade(assetFrom, balance, _assetTo);
    // }

    // TODO: calculate profit only. Now wrong.
    // forEach(feeManager.allowedAssets -> asset) {
    // 	uint256 balanceAsset = asset.balance(address(this));
    // 	uint256 feeAmount = balanceAsset * fee;
    // 	asset.transfer(feeManager, feeAmount);
    // 	asset.transfer(_investorTo, balanceDiff - feeAmount);
    // }

    // delete trader;
    // delete feeManager;

    // emit InvestorDeleted(investor, feeAsset[], feeAmount[]);

    // selfdestroy();
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
