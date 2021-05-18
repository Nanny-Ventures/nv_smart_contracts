// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDn.sol";
import "./DAOn.sol";

contract NV_DAO is Ownable {
  enum PortfolioRiskType {
    low,
    mid,
    high
  }

  struct Portfolio {
    PortfolioRiskType riskType;
    string name;
    address[] tokens;
    mapping(address => uint256) tokenIndex;
  }

  address public escrowLow;
  address public escrowMid;
  address public escrowHigh;

  uint256 public minInvestmentUSDT;
  mapping(PortfolioRiskType => Portfolio) public portfolios;
  
  
  modifier onlyExistingPortfolio(uint8 _riskType) {
    require(portfolios[PortfolioRiskType(_riskType)].tokens.length > 0, "Wrong portfolio _riskType");
    _;
  }


  /**
   * @dev Constructs Smart Contract.
   * @param _escrowLow Escrow low.
   * @param _escrowMid Escrow mid.
   * @param _escrowHigh Escrow high.
   */
  constructor(address _escrowLow, address _escrowMid, address _escrowHigh) {
    require(_escrowLow != address(0), "Wrong _escrowLow");
    require(_escrowMid != address(0), "Wrong _escrowMid");
    require(_escrowHigh != address(0), "Wrong _escrowHigh");

    _escrowLow = _escrowLow;
    _escrowMid = _escrowMid;
    _escrowHigh = _escrowHigh;
  }

  /**
   * @notice IMPORTANT: no validation for 0.
   * @dev Updates min investment in USDT.
   * @param _amount Amount to be set for min investment in USDT.
   */
  function updateMinInvestmentUSDT(uint256 _amount) external onlyOwner {
    minInvestmentUSDT = _amount;
  }

  /**
   * @dev Creates portfolio and adds to portfolios array.
   * @param _riskType Portfolio risk tolerance. 0 - low, 1 - mid, 2 - high
   * @param _name Portfolio name.
   * @param _tokens Tokens used for Portfolio trading.
   */
  function addPortfolio(uint8 _riskType, string memory _name, address[] memory _tokens) external onlyOwner {
    require(PortfolioRiskType(_riskType) <= PortfolioRiskType.high, "Wrong risk");
    require(bytes(_name).length > 0, "Empty name");
    require(bytes(portfolios[PortfolioRiskType(_riskType)].name).length == 0, "Risk type present");

    portfolios[PortfolioRiskType(_riskType)].riskType = PortfolioRiskType(_riskType);
    portfolios[PortfolioRiskType(_riskType)].name = _name;
    portfolios[PortfolioRiskType(_riskType)].tokens = _tokens;
    
    for (uint8 i = 0; i < _tokens.length; i ++) {
      address tokenAddr = _tokens[i];
      require(tokenAddr != address(0), "Wrong token address");
      portfolios[PortfolioRiskType(_riskType)].tokenIndex[tokenAddr] = i;
    }
  }

  /**
   * @dev Adds tokens to existing portfolio.
   * @param _riskType Portfolio risk tolerance to be updated.
   * @param _tokens Tokens to be added to portfolio.
   */
  function addTokensToPortfolio(uint8 _riskType, address[] memory _tokens) external onlyOwner {
    Portfolio storage portfolio = portfolios[PortfolioRiskType(_riskType)];
    require(bytes(portfolio.name).length > 0, "No portfolio");

    for (uint8 i = 0; i < _tokens.length; i ++) {
      address tokenAddr = _tokens[i];
      require(tokenAddr != address(0), "Wrong token address");
      require(!isTokenAddedToPortfolio(tokenAddr, _riskType), "Token added");

      portfolio.tokenIndex[tokenAddr] = portfolio.tokens.length;
      portfolio.tokens.push(tokenAddr);
    }
  }

  /**
   * @dev Removes tokens to existing portfolio.
   * @param _riskType Portfolio risk tolerance to be updated.
   * @param _tokens Tokens to be removed from portfolio.
   */
  function removeTokensToPortfolio(uint8 _riskType, address[] memory _tokens) external onlyOwner {
    Portfolio storage portfolio = portfolios[PortfolioRiskType(_riskType)];
    require(bytes(portfolio.name).length > 0, "No portfolio");

    for (uint8 i = 0; i < _tokens.length; i ++) {
      address tokenAddr = _tokens[i];
      require(isTokenAddedToPortfolio(tokenAddr, _riskType), "Token not added");
      
      uint256 idxToRemove = portfolio.tokenIndex[tokenAddr];
      address lastAddress = portfolio.tokens[portfolio.tokens.length-1];

      portfolio.tokenIndex[lastAddress] = idxToRemove;
      portfolio.tokens.pop();
    }
  }

  /**
   * @dev Gets portfoilio details.
   * @param _riskType Portfolio risk type.
   * @return riskType Portfolio risk type.
   * @return name Portfolio name.
   * @return tokens Tokens used for Portfolio trading.
   */
  function portfolioInfo(uint8 _riskType) external view onlyExistingPortfolio(_riskType) returns (uint8 riskType, string memory name, address[] memory tokens) {
    riskType = uint8(portfolios[PortfolioRiskType(_riskType)].riskType);
    name = portfolios[PortfolioRiskType(_riskType)].name;
    tokens = portfolios[PortfolioRiskType(_riskType)].tokens;
  }

  /**
   * @dev Checks if token is added to portfolio.
   * @param _address Token address.
   * @param _risk Portfolio risk.
   */
  function isTokenAddedToPortfolio(address _address, uint8 _risk) public view returns (bool) {
    Portfolio storage portfolio = portfolios[PortfolioRiskType(_risk)];
    if (portfolio.tokens.length == 0) {
        return false;
    }
    
    uint256 idx = portfolio.tokenIndex[_address];
    return portfolio.tokens[idx] == _address;
  }

  /**
   * @dev Invests into portfolio.
   * @param _riskType Portfolio risk type.
   * @param _amount Investment amount in USDT.
   */
  function invest(uint8 _riskType, uint256 _amount) external onlyExistingPortfolio(_riskType) {
    require(_amount > minInvestmentUSDT, "Wrong _amount");

    
  }
}
