// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./NV_Portfolio.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// import "./NV_FeeManager.sol";

contract NV_Admin is Ownable, Pausable {
  address public feeManager;

  mapping(address => bool) public isTrader;
  mapping(address => bool) public isStableAllowed;
  mapping(address => bool) public isForbidden;
  
  address[] public portfolios;
  mapping(address => address[]) public portfoliosOfInvestor;
  mapping(address => address) public investorOfPortfolio;


  event PortfolioCreated(uint8 portfolioType, address investor);
  event TraderUpdated(bool _make, address _trader);
  event StableAllowed(bool _allowed, address _stable);


  /**
   * @dev Updates address as a trader.
   * @param _make Whether make a trader or removes.
   * @param _trader Trader Address.
   */
  function updateTrader(bool _make, address _trader) external onlyOwner {
    isTrader[_trader] = _make;
    emit TraderUpdated(_make, _trader);
  }

  /**
   * @dev Updates stable coin as allowed.
   * @param _allowed Whether allow or not.
   * @param _stable Stable coin address.
   */
  function updateStableAllowed(bool _allowed, address _stable) external onlyOwner {
    isStableAllowed[_stable] = _allowed;
    emit StableAllowed(_allowed, _stable);
  }

  /**
   * @dev Updates address as forbidden to invest.
   * @param _forbidden Whether forbidden or not.
   * @param _addr Address.
   */
  function updateForbidden(bool _forbidden, address _addr) external onlyOwner {
    isForbidden[_addr] = _forbidden;
  }

  /**
   * @dev Updates FeeManager address.
   * @param _manager Manager address.
   */
  function updateFeeManager(address _manager) external onlyOwner {
    require(_manager != address(0), "Wrong manager");
    feeManager = _manager;
  }

  /**
   * @dev Gets all portfolios.
   * @param _startIdx Index to start with.
   * @param _endIdx Index to end on.
   * @return All portfolios.
   */
  function allPotfolios(uint256 _startIdx, uint256 _endIdx) external view returns(address[] memory) {
    if (_startIdx == 0 && _endIdx == 0) {
      return portfolios;
    }

    require(_startIdx <= _endIdx, "Wrong idxs");
    require(_endIdx < portfolios.length);

    address[] memory portfoliosLocal = new address[](_endIdx - _startIdx);
    uint256 loop;
    for (uint256 i = _startIdx; i <= _endIdx; i ++) {
      portfoliosLocal[loop] = portfolios[i];
      loop++;
    }

    return portfoliosLocal;
  }

  /**
   * @dev Creates portfolio for investor.
   * @param _riskTolerance Risk tolerance of the portfolio.
   */
  function createPortfolio(uint8 _riskTolerance) external whenNotPaused {
    require(!isForbidden[msg.sender], "Forbidden");
    
    address portfolioAddr = address(new NV_Portfolio(_riskTolerance, address(this)));

    portfolios.push(portfolioAddr);
    portfoliosOfInvestor[msg.sender].push(portfolioAddr);
    investorOfPortfolio[portfolioAddr] = msg.sender;

    emit PortfolioCreated(_riskTolerance, msg.sender);
  }


  /**
   * @dev Sells all assets owned and deletes portfolio.
   * @param _router Router address.
   * @param _stableAsset Asset (stable coin) to be used for profit withdrawal.
   * @param _addressTo Address profit should be sent to. msg.sender will used if 0x0.
   */
  function deletePortfolio(uint8 _slippage, address _portfolio, address _router, address _stableAsset, address _addressTo) external whenNotPaused {
    require(investorOfPortfolio[_portfolio] == msg.sender, "Not investor");

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

    NV_Portfolio(_portfolio).sellAllAssets(_stableAsset, _router, _slippage);

    // delete trader;
    // delete feeManager;

    // emit InvestorDeleted(investor, feeAsset[], feeAmount[]);

    // selfdestroy();
  }
}
