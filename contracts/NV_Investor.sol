// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "./NV_Admin.sol";
import "./NV_Portfolio.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NV_Investor is Ownable, ERC721Enumerable, ERC721URIStorage {
  address public admin;

  modifier onlyNotPaused() {
    require(!NV_Admin(admin).paused(), "Paused");
    _;
  }

  constructor() ERC721("NV_Investor", "NVI") {

  }

  /**
   * @dev Updates admin address.
   * @param _admin Admin address.
   */
  function updateAdmin(address _admin) external onlyOwner {
    admin = _admin;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal onlyNotPaused override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId) internal override (ERC721, ERC721URIStorage) {
    revert("No burn");
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }


  /**
   * @dev Creates portfolio for investor.
   * @param _type Type of portfolio.
   */
  function createPortfolio(uint8 _type) external onlyNotPaused {
    address portfolioAddr = address(new NV_Portfolio(_type, admin, totalSupply()));
    _safeMint(msg.sender, totalSupply());
    _setTokenURI(totalSupply()-1, addressToAsciiString(portfolioAddr));
  }


  /**
   * HELPERS
   */
  function addressToAsciiString(address x) private pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
      bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
      bytes1 hi = bytes1(uint8(b) / 16);
      bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
      s[2*i] = char(hi);
      s[2*i+1] = char(lo);
    }
    return string(abi.encodePacked("0x", s));
  }

  function char(bytes1 b) private pure returns (bytes1 c) {
    return (uint8(b) < 10) ? bytes1(uint8(b) + 0x30) : bytes1(uint8(b) + 0x57);
  }
}
