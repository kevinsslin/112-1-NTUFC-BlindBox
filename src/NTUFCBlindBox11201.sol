// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NTUFCBlindBox11201 is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public constant maxSupply = 500;
    uint256 public maxMint = 5;

    string internal baseURI;

    string public notRevealedUri; // for tokenURI before reveal
    string public baseExtension = ".json";

    bool public _revealed = false;

    // tokenId => tokenURI
    mapping(uint256 => string) private _tokenURIs;

    // _initBaseURI:
    constructor(
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    )
        ERC721("112-1 NTUFC Blind Box", "NTUFC11201")
    {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    function setRevealed(bool _isRevealed) public onlyOwner {
        _revealed = _isRevealed;
    }

    function freeMint(uint256 mintAmount) public payable {
        require(totalSupply() + mintAmount <= maxSupply, "Exceeds max supply");
        require(mintAmount <= maxMint, "Cannot mint that much tokens at a time");

        _mintBatch(mintAmount);
    }

    function _mintBatch(uint256 mintAmount) private {
        for (uint256 i = 0; i < mintAmount; ++i) {
            // tokenId starts from 0
            uint256 tokenId = totalSupply();
            _safeMint(msg.sender, tokenId);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Invalid token id");

        if (_revealed == false) {
            return notRevealedUri;
        }

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    // internal function
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    // for owner to withdraw profit
    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}
