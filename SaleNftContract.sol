// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract BoredApeYachtClub is ERC721, ERC721Enumerable, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint[] public onSaleNfts;  //array for nfts on sale
    mapping(uint => address) public nftOwners; // mapping tokenId to owners
    mapping(uint => uint) public prices;  // mapping tokenId to price
    mapping(uint => address) public creator;  // mapping tokenId to creator or minter

    constructor() ERC721("Bored Ape", "BAYC") {}

    function safeMint(address to) public payable {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        creator[tokenId] = msg.sender;
    }

    function putOnSale(uint tokenId, uint salePrice) public payable {
        require(msg.sender == ownerOf(tokenId));
        approve(address(this), tokenId);
        //safeTransferFrom(msg.sender, address(this), tokenId);
        onSaleNfts.push(tokenId);
        nftOwners[tokenId] = msg.sender;
        prices[tokenId] = salePrice;
    }

    function showPrice(uint tokenId) public view returns (uint) {
        return prices[tokenId];
    }

    function purchase(uint tokenId) external payable {
        require(msg.value >= prices[tokenId]);
        safeTransferFrom(ownerOf(tokenId), msg.sender, tokenId);
        uint val = msg.value;
        uint sval = val * 90 / 100;
        uint oval = val * 10 / 100;
        payable(nftOwners[tokenId]).transfer(sval);
        payable(creator[tokenId]).transfer(oval);
        delete nftOwners[tokenId];
        delete prices[tokenId];
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}