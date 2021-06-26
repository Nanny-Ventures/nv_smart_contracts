// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./NV_Admin.sol";
import "./interfaces/NV_IRouter.sol";
import "./interfaces/NV_IPortfolio.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NV_Portfolio is NV_IPortfolio {

  uint8 public riskTolerance; //  low, mid, high
  address public admin;

  uint256 public stableFromAmount;
  uint256 public stableToAmount;

  uint256 public tradingFees; //  fee spent for trading that should be used while investor withdraws. Transfers & resets on each withdrawal.
  uint256 public withdrawalRequestedAt;
  address public withdrawalRequestedToAsset;

  address[] public assetsOwned;
  mapping (address => uint256) private assetOwnedIdx;

  event Trade(address indexed _assetFrom, uint256 _assetFromAmount, address indexed _assetTo, address indexed _routerUniAddr);


  /**
   * @dev Constructor.
   * @param _riskTolerance _riskTolerance value.
   * @param _admin _admin Smart Contract address.
   */
  constructor(uint8 _riskTolerance, address _admin) {
    require(_riskTolerance < 3, "Wrong risk");
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
   * @dev Converts stables.
   * @param _slippage Slippage value.
   * @param _assetFrom Asset address to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   */
  function convertStables(uint8 _slippage, address _assetFrom, address _assetTo, address _router) external {
    require(NV_Admin(admin).isTrader(msg.sender), "Not trader");
    uint256 _assetFromBalance = IERC20(_assetFrom).balanceOf(address(this));

    NV_IRouter(_router).trade(_slippage, _assetFrom, _assetFromBalance, _assetTo);
  }

  /**
   * @dev Performs trade with specified amount.
   * @param _delete Whether delete portfolio or not.
   * @param _assetFrom Asset address to sell.
   * @param _assetFromAmount Amount of _assetFrom to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function _tradeAmount(bool _delete, uint8 _slippage, address _assetFrom, uint256 _assetFromAmount, address _assetTo, address _router) private {
    uint256 gasAmount = gasleft();

    (_delete) ? require(msg.sender == admin, "Not admin") : require(NV_Admin(admin).isTrader(msg.sender), "Not trader");
    require(_assetFromAmount > 0, "Wrong _assetFromAmount");
    require(_assetTo != address(0), "Wrong _assetTo");
    require(_router != address(0), "Wrong _router");
    require(!NV_Admin(admin).paused(), "On pause");

    uint256 _assetFromBalance = IERC20(_assetFrom).balanceOf(address(this));
    require(_assetFromBalance >= _assetFromAmount, "Wrong _assetFromBalance");

    if (IERC20(_assetFrom).allowance(address(this), _router) == 0) {
      IERC20(_assetFrom).approve(_router, ((2**256) - 1));
    }

    uint256 assetToAmount = NV_IRouter(_router).trade(_slippage, _assetFrom, _assetFromAmount, _assetTo);
    if (NV_Admin(admin).isStableAllowed(_assetFrom)) {
      stableFromAmount += _assetFromAmount;
    } else {
      require(NV_Admin(admin).isStableAllowed(_assetTo), "No stable");
      stableToAmount += assetToAmount;
    }
    
    if (!isAssetOwned(_assetTo)) {
      addOwnedAsset(_assetTo);
    }

    if (IERC20(_assetFrom).balanceOf(address(this)) == 0) {
      removeOwnedAsset(_assetFrom);
    }

    emit Trade(_assetFrom, _assetFromAmount, _assetTo, _router);

    gasAmount -= gasleft();
    tradingFees += (21000 + gasAmount) * tx.gasprice;
  }

  /**
   * @dev Performs trade with specified amount.
   * @param _assetFrom Asset address to sell.
   * @param _assetFromAmount Amount of _assetFrom to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function tradeAmount(uint8 _slippage, address _assetFrom, uint256 _assetFromAmount, address _assetTo, address _router) public {
    _tradeAmount(false, _slippage, _assetFrom, _assetFromAmount, _assetTo, _router);
  }

  /**
   * @dev Performs trade with specified percentage.
   * @param _slippage Slippage value.
   * @param _assetFromPercentage Percentage of _assetFrom to sell.
   * @param _assetFrom Asset address to sell.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   */
  function tradePercentage(uint8 _slippage, uint8 _assetFromPercentage, address _assetFrom, address _assetTo, address _router) external {
    uint256 _assetFromBalance = IERC20(_assetFrom).balanceOf(address(this));
    require(_assetFromBalance > 0, "Wrong _assetFromBalance");

    _tradeAmount(false, _slippage, _assetFrom, ((_assetFromBalance * _assetFromPercentage) / 100), _assetTo, _router);
  }

  /**
   * @dev Sells all owned assets.
   * @param _delete Whether delete portfolio or not.
   * @param _assetTo Asset address to buy.
   * @param _router Router address.
   * @param _slippage Slippage value.
   */
  function sellAllAssets(bool _delete, uint8 _slippage, address _assetTo, address _router) external override {
    uint256 assetsLength = assetsOwned.length;

    for (uint256 i = 0; i < assetsLength; i ++) {
      uint256 _assetFromBalance = IERC20(assetsOwned[i]).balanceOf(address(this));
      _tradeAmount(_delete, _slippage, assetsOwned[i], _assetFromBalance, _assetTo, _router);
    }
  }

  /**
   * @dev Requests for withdrawal.
   * @param _assetTo Asset (stable coin) to be used for balance withdrawal.
   */
  function requestForWithdrawal(address _assetTo) external {
    require(NV_Admin(admin).isStableAllowed(_assetTo), "Wrong stable");

    uint256 requestDuration = NV_Admin(admin).requestDuration();
    
    require(!NV_Admin(admin).paused(), "On pause");
    require(NV_Admin(admin).investorOfPortfolio(address(this)) == msg.sender, "Not investor");
    require((withdrawalRequestedAt + requestDuration * 5) > block.timestamp, "Not yet");

    withdrawalRequestedAt = block.timestamp;
    withdrawalRequestedToAsset = _assetTo;
  }

  /**
   * @dev Withdraws balance.
   * @param _percentageToWithdraw Percentage of balance to withdraw.
   * @param _assetTo Asset (stable coin) to be used for balance withdrawal.
   * @param _addressTo Receiver address. msg.sender will used if 0x0.
   */
  function withdrawBalance(uint8 _percentageToWithdraw, address _assetTo, address _addressTo) external override {
    require(_percentageToWithdraw > 0, "Wrong percentage");
    require(NV_Admin(admin).isStableAllowed(_assetTo), "Wrong stable");
    require(_addressTo != address(0), "Wrong addressTo");
    require(NV_Admin(admin).investorOfPortfolio(address(this)) == msg.sender, "Not investor");
    require(!NV_Admin(admin).paused(), "On pause");
    require(assetsOwned.length == 0, "Present assetsOwned");    //  there must be no assetsOwned. Trader must sell all assetsOwned.

    address[] memory stablesAllowed = NV_Admin(admin).getStablesAllowed();
    for (uint256 i = 0; i < stablesAllowed.length; i++) {
      if (stablesAllowed[i] != _assetTo) {
        require(IERC20(stablesAllowed[i]).balanceOf(address(this)) == 0, "Multiple stable bal");  //  there must be single stable with balance. Trader must convert other stables into single.
      }
    }

    uint256 balance = IERC20(_assetTo).balanceOf(address(this));
    require(balance > 0, "No balance");

    uint256 requestDuration = NV_Admin(admin).requestDuration();
    uint8 feePercentage;
    uint256 profit;
    
    if (stableToAmount > stableFromAmount) {
      feePercentage = NV_Admin(admin).successFeePercentage();
      profit = stableToAmount - stableFromAmount;
    }
    
    if ((block.timestamp < withdrawalRequestedAt + requestDuration) || (block.timestamp > withdrawalRequestedAt + (requestDuration * 2))) {
      feePercentage += NV_Admin(admin).urgentFeePercentage();
    }

    uint256 feeAmount;
    if (feePercentage > 0) {
      if (profit > 0) {
        feeAmount = ((profit * feePercentage) / 100) + tradingFees;

        delete tradingFees;
        delete stableFromAmount;
        delete stableToAmount;
      } else {
        feeAmount = ((balance * feePercentage) / 100) + tradingFees;
      }

      if (feeAmount > 0) {
        require(IERC20(_assetTo).transfer(NV_Admin(admin).devFeeDistributionManager(), feeAmount), "Transfer to dev failed");
      }
    }

    balance = ((balance - feeAmount) * _percentageToWithdraw) / 100;
    require(IERC20(_assetTo).transfer(_addressTo, balance), "Transfer to investor failed");
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
    return assetsOwned[assetOwnedIdx[_asset]] == _asset;
  }

  /**
   * @dev Adds asset to the assetsOwned.
   * @param _asset Asset address.
   */
  function addOwnedAsset(address _asset) private {
    assetOwnedIdx[_asset] = assetsOwned.length;
    assetsOwned.push(_asset);
  }

  /**
   * @dev Removes asset from the assetsOwned.
   * @param _asset Asset address.
   */
  function removeOwnedAsset(address _asset) private {
    uint256 idxToDelete = assetOwnedIdx[_asset];

    if (idxToDelete < assetsOwned.length - 1) {
      address lastAsset = assetsOwned[assetsOwned.length - 1];
      assetOwnedIdx[lastAsset] = idxToDelete;
      assetsOwned[idxToDelete] = lastAsset;
    }
    delete assetOwnedIdx[_asset];
    assetsOwned.pop();
  }
}
