//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.16;

interface ISBT {
    function tokenOf(address owner) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
