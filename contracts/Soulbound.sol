//SPDX-License-Identifier: Unlicense

pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract Soulbound is EIP712 {
    using Strings for uint256;

    address verifier;

    string public name = "Karma Token";
    string public symbol = "KT";

    string public baseURI;

    struct MintParams {
        address verifier;
        address to;
        uint256 tokenId;
        uint256 nonce;
    }

    bytes32 private constant MINT_TYPEHASH =
        keccak256(
            "Mint(address verifier,address to,uint256 tokenId,uint256 nonce)"
        );

    uint256 public nonce; 

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

    constructor(address _verifier, string memory _baseURI) EIP712(name, "1") {
        verifier = _verifier;
        baseURI = _baseURI;
    }

    function mint(MintParams calldata params, bytes calldata signature) external {
        require(params.nonce == nonce, "KT: invalid nonce");
        require(params.to != address(0), "KT: mint to the zero address");
        require(!_exists(params.tokenId), "KT: token already minted");
        require(balances[params.to] == 0, "KT: Can have only one token.");

        bytes32 structHash = keccak256(
            abi.encode(
                MINT_TYPEHASH,
                params.verifier,
                params.to,
                params.tokenId,
                params.nonce
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, signature);
        require(signer == verifier, "KT: Signer is not verifier");

        unchecked {
            balances[params.to] += 1;
        }

        owners[params.tokenId] = params.to;
        nonce++;
        emit Minted(params.to, params.tokenId);
    }

    function burn(uint256 tokenId) external tokenExists(tokenId) {
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
