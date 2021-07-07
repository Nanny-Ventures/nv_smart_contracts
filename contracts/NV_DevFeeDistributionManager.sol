// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NV_DevFeeDistributionManager {

  address[4] public adresses = [address(0), address(0), address(0), address(0)];  // TODO: correct addresses
  uint256[4] public percentages = [40, 40, 20, 10];

  modifier onlyValidCaller() {
    for (uint8 i = 0; i < 3; i++) {
      if (adresses[i] == msg.sender) {
        _;
      }
    }
    revert("Wrong caller");
  }

  /**
   * @dev Distributes profit among parties & Withdraws it.
   * @param _token address.
   */
  function withdrawProfit(address _token) external onlyValidCaller {
    uint256 balance = IERC20(_token).balanceOf(address(this));

    uint256 amountPerc_0 = (balance * percentages[0]) / 100;
    uint256 amountPerc_1 = (balance * percentages[1]) / 100;
    uint256 amountPerc_2 = (balance * percentages[2]) / 100;
    uint256 amountPerc_3 = balance - amountPerc_0 - amountPerc_1 - amountPerc_2;

    IERC20(_token).transfer(adresses[0], amountPerc_0);
    IERC20(_token).transfer(adresses[1], amountPerc_1);
    IERC20(_token).transfer(adresses[2], amountPerc_2);
    IERC20(_token).transfer(adresses[3], amountPerc_3);
  }
}