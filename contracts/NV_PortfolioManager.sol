// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./NV_Portfolio.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract NV_PortfolioManager is Ownable, Pausable {
  address[] public stablesAllowed;

  address[] public activePortfolios;
  address[] public inactivePortfolios;

  mapping(address => bool) public isStableAllowed;
  mapping(address => uint256) private indexOfActivePortfolio;
  mapping(address => address[]) public portfoliosOfInvestor;
  mapping(address => address) public investorOfPortfolio;
  mapping(address => bool) public isInvestorForbidden;


  event StableAllowed(bool _allowed, address _stable);
  event PortfolioCreated(uint8 portfolioType, address portfolio, address investor);
  event PortfolioDeleted(address portfolio, address investor);


  /**
   * @dev Updates stable coin as allowed.
   * @param _allowed Whether allow or not.
   * @param _stable Stable coin address.
   */
  function updateStableAllowed(bool _allowed, address _stable) external onlyOwner {
    require(isStableAllowed[_stable] != _allowed, "Wrong allowed");
    isStableAllowed[_stable] = _allowed;

    if (_allowed) {
      stablesAllowed.push(_stable);
    } else {
      for (uint8 i = 0; i < stablesAllowed.length; i++) {
        if (stablesAllowed[i] == _stable) {
          stablesAllowed[i] = stablesAllowed[stablesAllowed.length - 1];
          stablesAllowed.pop();
        }
      }
    }

    emit StableAllowed(_allowed, _stable);
  }

  /**
   * @dev Updates address as forbidden to invest.
   * @param _forbidden Whether forbidden or not.
   * @param _addr Address.
   */
  function updateForbiddenInvestor(bool _forbidden, address _addr) external onlyOwner {
    isInvestorForbidden[_addr] = _forbidden;
  }

  /**
   * @notice (0, 0) - entire array. 
   * @dev Gets all active portfolios.
   * @param _startIdx Index to start with.
   * @param _endIdx Index to end on.
   * @return All active portfolios.
   */
  function getActivePortfolios(uint256 _startIdx, uint256 _endIdx) external view returns(address[] memory) {
    if (_startIdx == 0 && _endIdx == 0) {
      return activePortfolios;
    }

    require(_startIdx <= _endIdx, "Wrong idxs");
    require(_endIdx < activePortfolios.length);

    address[] memory portfoliosLocal = new address[](_endIdx - _startIdx);
    uint256 loop;
    for (uint256 i = _startIdx; i <= _endIdx; i ++) {
      portfoliosLocal[loop] = activePortfolios[i];
      loop++;
    }

    return portfoliosLocal;
  }

  /**
   * @notice (0, 0) - entire array.
   * @dev Gets all inactive portfolios.
   * @param _startIdx Index to start with.
   * @param _endIdx Index to end on.
   * @return All inactive portfolios.
   */
  function getInactivePortfolios(uint256 _startIdx, uint256 _endIdx) external view returns(address[] memory) {
    if (_startIdx == 0 && _endIdx == 0) {
      return inactivePortfolios;
    }

    require(_startIdx <= _endIdx, "Wrong idxs");
    require(_endIdx < inactivePortfolios.length);

    address[] memory portfoliosLocal = new address[](_endIdx - _startIdx);
    uint256 loop;
    for (uint256 i = _startIdx; i <= _endIdx; i ++) {
      portfoliosLocal[loop] = inactivePortfolios[i];
      loop++;
    }

    return portfoliosLocal;
  }

  /**
   * @dev Gets portolios for investor count.
   * @dev _investor Investor address.
   * @return Portfolios count.
   */
  function portfoliosOfInvestorCount(address _investor) external view returns(uint256) {
    return portfoliosOfInvestor[_investor].length;
  }

  /**
   * @dev Creates portfolio for investor.
   * @param _riskTolerance Risk tolerance of the portfolio.
   */
  function createPortfolio(uint8 _riskTolerance) external whenNotPaused {
    require(!isInvestorForbidden[msg.sender], "Forbidden");
    
    address portfolioAddr = address(new NV_Portfolio(_riskTolerance, address(this)));

    indexOfActivePortfolio[portfolioAddr] = activePortfolios.length;
    activePortfolios.push(portfolioAddr);
    portfoliosOfInvestor[msg.sender].push(portfolioAddr);
    investorOfPortfolio[portfolioAddr] = msg.sender;

    emit PortfolioCreated(_riskTolerance, portfolioAddr, msg.sender);
  }

  /**
   * @dev Sells all assets owned and deletes portfolio.
   * @param _router Router address.
   * @param _assetTo Asset (stable coin) to be used for balance withdrawal.
   * @param _addressTo Receiver address. msg.sender will used if 0x0.
   */
  function deletePortfolio(uint8 _slippage, address _portfolio, address _router, address _assetTo, address _addressTo) external whenNotPaused {
    uint256 idxToDelete = indexOfActivePortfolio[_portfolio];
    require(activePortfolios[idxToDelete] == _portfolio, "Wrong portfolio");
    require(investorOfPortfolio[_portfolio] == msg.sender, "Not investor");

    NV_Portfolio(_portfolio).sellAllAssets(_slippage, _assetTo, _router);

    uint8 stablesAllowedLength = uint8(stablesAllowed.length);
    for (uint8 i = 0; i < stablesAllowedLength; i++) {
      NV_Portfolio(_portfolio).withdrawBalance(100, stablesAllowed[i], _addressTo);
    }

    inactivePortfolios.push(_portfolio);

    if (idxToDelete == activePortfolios.length - 1) {
      activePortfolios.pop();
      delete indexOfActivePortfolio[_portfolio];
    } else {
      address lastPortfolio = activePortfolios[activePortfolios.length - 1];
      indexOfActivePortfolio[lastPortfolio] = idxToDelete;
      activePortfolios[idxToDelete] = lastPortfolio;
      activePortfolios.pop();
    }

    emit PortfolioDeleted(_portfolio, msg.sender);
  }
}
