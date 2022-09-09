//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.16;

import "./ISBT.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract Soulbound is IERC721, EIP712, ISBT {
    using Strings for uint256;

    address private verifier;

    string public name = "Karma Token";
    string public symbol = "KT";

    struct MintParams {
        address verifier;
        address to;
        uint256 nonce;
        string uri;
    }

    bytes32 private constant MINT_TYPEHASH =
        keccak256("Mint(address verifier,address to,uint256 nonce,string uri)");

    // Mapping from token ID to owner address
    mapping(uint256 => address) private owners;
    // Mapping from owner address to his token
    mapping(address => uint256) private tokens;
    // Mapping from token to its URI
    mapping(uint256 => string) private tokenUris;
    // Keeping track of nonces of every user
    mapping(address => uint256) public nonces;
    // Track ID
    uint256 public currentTokenId = 1;

    // Emitted when a soulbound is issued to a soul
    event Minted(address indexed to, uint256 indexed tokenId);
    // Emitted when an issuer burns a soul
    event IssuerRevoke(address indexed from, uint256 indexed tokenId);
    // Emitted when an owner burns a soul
    event OwnerRevoke(address indexed from, uint256 indexed tokenId);

    // Checks if token actually exists
    modifier tokenExists(uint256 tokenId) {
        require(_exists(tokenId), "SBT: Token does not exist.");
        _;
    }

    modifier onlyVerifier() {
        require(msg.sender == verifier, "SBT: Sender is not verifier");
        _;
    }

    constructor(address _verifier) EIP712(name, "1") {
        verifier = _verifier;
    }

    function mint(MintParams calldata params, bytes calldata signature)
        external
    {
        require(params.nonce == nonces[msg.sender], "SBT: invalid nonce");
        require(params.to != address(0), "SBT: mint to the zero address");
        require(tokens[params.to] == 0, "SBT: Can have only one token.");

        bytes32 structHash = keccak256(
            abi.encode(
                MINT_TYPEHASH,
                params.verifier,
                params.to,
                params.nonce,
                keccak256(abi.encodePacked(params.uri))
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, signature);
        require(signer == verifier, "SBT: Signer is not verifier");

        uint256 id = currentTokenId;
        owners[id] = params.to;
        tokens[params.to] = id;
        tokenUris[id] = params.uri;

        unchecked {
            currentTokenId++;
        }

        emit Minted(params.to, id);
    }

    function burn() external {
        address owner = msg.sender;
        uint256 tokenId = tokens[owner];
        _burn(owner, tokenId);
        emit OwnerRevoke(owner, tokenId);
    }

    function burnFrom(address owner) external onlyVerifier {
        uint256 tokenId = tokens[owner];
        _burn(owner, tokenId);
        emit IssuerRevoke(owner, tokenId);
    }

    function tokenOf(address owner) external view returns (uint256) {
        require(owner != address(0), "SBT: Invalid owner");
        return tokens[owner];
    }

    function ownerOf(uint256 tokenId)
        external
        view
        override (IERC721, ISBT)
        tokenExists(tokenId)
        returns (address)
    {
        return _ownerOf(tokenId);
    }

    function tokenURI(uint256 tokenId)
        external
        override
        view
        tokenExists(tokenId)
        returns (string memory)
    {
        return tokenUris[tokenId];
    }

    function _burn(address owner, uint256 tokenId) internal {
        require(tokenId != 0, "SBT: Cannot burn empty");
        delete owners[tokenId];
        delete tokens[owner];
        delete tokenUris[tokenId];
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

    }

    function balanceOf(address owner) external view returns (uint256 balance) {

    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes calldata
    ) external { revert("Unsupported"); }

    function safeTransferFrom(
        address,
        address,
        uint256
    ) external { revert("Unsupported"); }

    function transferFrom(
        address,
        address,
        uint256
    ) external { revert("Unsupported"); }

    function approve(address, uint256) external { revert("Unsupported"); }

    function setApprovalForAll(address, bool) external {revert("Unsupported");}

    function getApproved(uint256) external virtual view returns (address) { revert("Unsupported"); }

    function isApprovedForAll(address, address) external view returns (bool) {revert("Unsupported"); }


    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return owners[tokenId];
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
