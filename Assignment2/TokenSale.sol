// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./Counters.sol";
import "./ReentrancyGuard.sol";
import "./Ownable.sol";

contract TokenSale is ERC721, ReentrancyGuard, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter tokenIds;

    uint tokenPrice = 0.5 ether;
    mapping(address => uint) userTokenCount;

    event TokenPurchased(address indexed user, uint tokenId, uint amount);

    constructor() ERC721("Assignment2-NFT-Collection", "ANC") {
        setBaseURI("https://gateway.pinata.cloud/ipfs/QmS56crkn85CjkXPRnayNTBuNTcQpoAFJLdMGgAa65bRHo/");
    }

    function purchaseToken() public payable nonReentrant {
        require(tokenIds.current() < 100, "TokenSale: Token Sale has been ended!");
        require(userTokenCount[msg.sender] < 10, "TokenSale: You cannot have more than 10 NFTs");  // < 10 because mapping starts at 0
        require(msg.value >= tokenPrice, "Insufficient amount to purchase token");
        uint tokenId = mint();
        address payable owner  = payable(getOwner());
        owner.transfer(address(this).balance);
        emit TokenPurchased(msg.sender, tokenId, msg.value);
    }    

    function mint() private returns(uint) {
        tokenIds.increment();
        uint currentTokenId = tokenIds.current();
        _safeMint(msg.sender, currentTokenId);
        userTokenCount[msg.sender] += 1;
        return currentTokenId;
    }
}