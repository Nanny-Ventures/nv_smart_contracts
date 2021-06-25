// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/NV_IPortfolio.sol";
import "./interfaces/NV_IPortfolioFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract NV_PortfolioManager is Ownable, Pausable {
  address internal portfolioFactory;

  address[] public stablesAllowed;
  address[] public activePortfolios;
  address[] public inactivePortfolios;

  mapping(address => bool) public isStableAllowed;
  mapping(address => uint256) private indexOfActivePortfolio;
  mapping(address => address[]) public portfoliosOfInvestor;  //  all created portfolios currently owning
  mapping(address => address) public investorOfPortfolio;
  mapping(address => bool) public isInvestorForbidden;

  event StableAllowed(bool allowed, address stable);
  event PortfolioCreated(uint8 portfolioType, address portfolio, address investor);
  event PortfolioDeleted(address portfolio, address investor);
  event PortfolioTransferred(address from, address to);


  /**
   * @notice removed stablecoin balance in portfolio will be locked.
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
   * @notice Should be called by investor directly.
   * @dev Creates portfolio for investor.
   * @param _riskTolerance Risk tolerance of the portfolio.
   */
  function createPortfolio(uint8 _riskTolerance) external whenNotPaused {
    require(!isInvestorForbidden[msg.sender], "Investor forbidden");
    
    address portfolioAddr = NV_IPortfolioFactory(portfolioFactory).createPortfolio(_riskTolerance);

    indexOfActivePortfolio[portfolioAddr] = activePortfolios.length;
    activePortfolios.push(portfolioAddr);
    portfoliosOfInvestor[msg.sender].push(portfolioAddr);
    investorOfPortfolio[portfolioAddr] = msg.sender;

    emit PortfolioCreated(_riskTolerance, portfolioAddr, msg.sender);
  }

  /**
   * @dev Transfers portfolio ownership between investors.
   * @param _portfolio Portfolio address.
   * @param _to Transfer to address.
   */
  function transferPortfolio(address _portfolio, address _to) external whenNotPaused {
    uint256 idx = indexOfActivePortfolio[_portfolio];
    require(activePortfolios[idx] == _portfolio, "Wrong portfolio");
    require(investorOfPortfolio[_portfolio] == msg.sender, "Not investor");
    require(!isInvestorForbidden[_to], "Investor forbidden");

    portfoliosOfInvestor[_to].push(_portfolio);
    investorOfPortfolio[_portfolio] = _to;

    uint256 portfoliosAmount = portfoliosOfInvestor[msg.sender].length;
    for (uint256 i = 0; i < portfoliosAmount; i++) {
      if (portfoliosOfInvestor[msg.sender][i] == _portfolio) {
        if (i < (portfoliosAmount - 1)) {
          portfoliosOfInvestor[msg.sender][i] = portfoliosOfInvestor[msg.sender][portfoliosAmount - 1];
        }
        portfoliosOfInvestor[msg.sender].pop();
      }
    }

    emit PortfolioTransferred(msg.sender, _to);
  }

  /**
   * @notice Should be called by investor directly.
   * @dev Sells all assets owned and deletes portfolio.
   * @param _router Router address.
   * @param _assetTo Asset (stable coin) to be used for balance withdrawal.
   * @param _addressTo Receiver address. msg.sender will used if 0x0.
   */
  function deletePortfolio(uint8 _slippage, address _portfolio, address _router, address _assetTo, address _addressTo) external whenNotPaused {
    uint256 idxToDelete = indexOfActivePortfolio[_portfolio];
    require(activePortfolios[idxToDelete] == _portfolio, "Wrong portfolio");
    require(investorOfPortfolio[_portfolio] == msg.sender, "Not investor");

    NV_IPortfolio(_portfolio).sellAllAssets(_slippage, _assetTo, _router);

    uint8 stablesAllowedLength = uint8(stablesAllowed.length);
    for (uint8 i = 0; i < stablesAllowedLength; i++) {
      NV_IPortfolio(_portfolio).withdrawBalance(100, stablesAllowed[i], _addressTo);
    }

    inactivePortfolios.push(_portfolio);

    if (idxToDelete < activePortfolios.length - 1) {
      address lastPortfolio = activePortfolios[activePortfolios.length - 1];
      indexOfActivePortfolio[lastPortfolio] = idxToDelete;
      activePortfolios[idxToDelete] = lastPortfolio;
    }
    delete indexOfActivePortfolio[_portfolio];
    activePortfolios.pop();

    emit PortfolioDeleted(_portfolio, msg.sender);
  }
}
