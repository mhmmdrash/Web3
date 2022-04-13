// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BoredApeYachtClub is ERC721, ERC721Enumerable, ERC721Burnable, Ownable, IERC721Receiver {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint[] public onSaleNfts;  //array for nfts on sale
    
    mapping(uint => uint) public prices;  // mapping tokenId to price
    mapping(uint => address) public creator;  // mapping tokenId to creator or minter

    mapping(uint => address) public bidders;
    mapping(address => uint) public bids;
    enum bidState {Active, InActive}
    bidState public currState;

    // modifiers

    modifier isActive() {
        require(currState == bidState.Active);
        _;
    }

    modifier onlySeller(uint tokenId) {
        require(msg.sender == ownerOf(tokenId));
        _;
    }

    modifier neverSeller(uint tokenId) {
        require(msg.sender != ownerOf(tokenId));
        _;
    }

    constructor() ERC721("Bored Ape", "BAYC") {
        _tokenIdCounter._value = 1;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function safeMint(address to) public payable {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        creator[tokenId] = msg.sender;
    }

    function putOnSale(uint tokenId, uint salePrice) public {
        require(msg.sender == ownerOf(tokenId));
        //safeTransferFrom(msg.sender, address(this), tokenId);
        onSaleNfts.push(tokenId);
        // nftOwners[tokenId] = msg.sender;
        prices[tokenId] = salePrice;
    }

    function showPrice(uint tokenId) public view returns (uint) {
        return prices[tokenId];
    }

    function bid(uint tokenId, uint _bid) external neverSeller(tokenId) {
        require(_bid >= prices[tokenId]);
        require(msg.sender != ownerOf(tokenId));
        bidders[_bid] = msg.sender;
        bids[msg.sender] = _bid;
        currState == bidState.Active;
    }

    function acceptBid(uint tokenId, uint _bid ) external onlySeller(tokenId) isActive {
        approve(bidders[_bid], tokenId);
    }

    function purchase(uint tokenId) external payable {
        require(msg.value >= bids[msg.sender]);
        uint val = msg.value;
        uint sval = val * 90 / 100;
        uint oval = val * 10 / 100;
        payable(ownerOf(tokenId)).transfer(sval);
        payable(creator[tokenId]).transfer(oval);
        safeTransferFrom(ownerOf(tokenId), msg.sender, tokenId);
        delete prices[tokenId];
        delete bids[msg.sender];
        delete bidders[tokenId];
        onSaleNfts.pop();
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
