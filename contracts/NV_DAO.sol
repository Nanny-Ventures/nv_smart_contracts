// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

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
    mapping(address => bool) tokenUsed;
  }

  uint256 public minInvestmentUSDT;
  Portfolio[] private portfolios;
  
  modifier onlyExistingPortfolio(uint8 _id) {
      require(_id < portfolios.length, "Wrong portfolio id");
      _;
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
   * @dev Creates portfolio and adde to portfolios array.
   * @param _riskType Portfolio risk tolerance.
   * @param _name Portfolio name.
   * @param _tokens Tokens used for Portfolio trading.
   */
  function addPortfolio(uint8 _riskType, string memory _name, address[] memory _tokens) external onlyOwner {
    require(PortfolioRiskType(_riskType) <= PortfolioRiskType.high, "Wrong risk");
    require(bytes(_name).length > 0, "Empty name");

    for(uint8 i = 0; i < portfolios.length; i ++) {
      require(portfolios[i].riskType != PortfolioRiskType(_riskType), "Risk is present");
      require(keccak256(bytes(portfolios[i].name)) != keccak256(bytes(_name)), "Name used");
    }

    uint256 id = portfolios.length;
    portfolios[id].riskType = PortfolioRiskType(_riskType);
    portfolios[id].name = _name;
    portfolios[id].tokens = _tokens;
    
    for(uint8 i = 0; i < _tokens.length; i ++) {
      address tokenAddr = _tokens[i];
      require(tokenAddr != address(0), "Wrong token address");
      portfolios[id].tokenUsed[tokenAddr] = true;
    }
  }

  /**
   * @dev Gets portfoilio details.
   * @param _id Portfolio id.
   * @return _riskType Portfolio risk type.
   * @return _name Portfolio name.
   * @return _tokens Tokens used for Portfolio trading.
   */
  function portfolioInfo(uint8 _id) external view onlyExistingPortfolio(_id) returns (uint8 _riskType, string memory _name, address[] memory _tokens) {
    _riskType = uint8(portfolios[_id].riskType);
    _name = portfolios[_id].name;
    _tokens = portfolios[_id].tokens;
  }

  /**
   * @dev Invests into portfolio.
   * @param _id Portfolio id.
   * @param _amount Investment amount in USDT.
   */
  function invest(uint8 _id, uint256 _amount) external onlyExistingPortfolio(_id) {
    require(_amount > minInvestmentUSDT, "Wrong _amount");
  }
}
