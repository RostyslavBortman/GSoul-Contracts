//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Soulbound {
    using Strings for uint256;

    // Address that has can issue a soulbound
    address issuer;

    string public name = "Karma Token";
    string public symbol = "KT";
    

    string public baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private owners;
    // Mapping owner address to token count
    mapping(address => uint256) private balances;

    // Emitted when a soulbound is issued to a soul
    event Minted(address indexed to, uint256 indexed tokenId);
    // Emitted when a soulbound was burned from a soul
    event IssuerRevoke(address indexed from, uint256 indexed tokenId);

    // Checks if token actually exists
    modifier tokenExists(uint256 tokenId) {
        require(_exists(tokenId), "KT: Token does not exist.");
        _;
    }
    // Checks if call is being performed by an issuer
    modifier onlyIssuer() {
        require(msg.sender == issuer, "KT: Sender is not issuer.");
        _;
    }

    constructor(address _issuer, string memory _baseURI) {
        issuer = _issuer;
        baseURI = _baseURI;
    }

    function mint(address to, uint256 tokenId) external onlyIssuer {
        require(to != address(0), "KT: mint to the zero address");
        require(!_exists(tokenId), "KT: token already minted");

        unchecked {
            balances[to] += 1;
        }

        owners[tokenId] = to;
        emit Minted(to, tokenId);
    }

    function burn(uint256 tokenId) external onlyIssuer tokenExists(tokenId) {
        address owner = _ownerOf(tokenId);
        balances[owner] -= 1;
        delete owners[tokenId];

        emit IssuerRevoke(owner, tokenId);
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "KT: Invalid owner");
        return balances[owner];
    }

    function ownerOf(uint256 tokenId)
        external
        view
        tokenExists(tokenId)
        returns (address)
    {
        return _ownerOf(tokenId);
    }

    function tokenURI(uint256 tokenId)
        external
        view
        tokenExists(tokenId)
        returns (string memory)
    {
        string memory _baseURI = baseURI;
        return
            bytes(_baseURI).length > 0
                ? string(abi.encodePacked(_baseURI, tokenId.toString()))
                : "";
    }


    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return owners[tokenId];
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
