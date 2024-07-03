// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol";
import "https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol";

contract Moonimal is ERC721A, Ownable {
    uint256 public constant mintPrice = 0.001 ether;
    uint256 public constant maxMintPerUser = 4;
    uint256 public constant maxMintSupply = 100;

    uint256 public constant refundPeriod = 10 minutes; 
    uint256 public refundEndTimestamp;

    address public refundAddress;

    mapping(uint256 => uint256) public refundEndTimestamps;
    mapping(uint256 => bool) public hasRefunded; 

    constructor(address initialOwner)
        ERC721A("Moonimal", "MNM")
        Ownable(initialOwner)
    {
        refundAddress = address(this);
        refundEndTimestamp = block.timestamp + refundPeriod;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmRDUT4P7ac347sAC5eG8xhkm8R4Mic2eKq4uZczjQbwQL/";
    }

    function safeMint(uint256 quantity) public payable {    
        require(msg.value >= mintPrice * quantity, "Not enough funds");
        //numberMinted is function from ERC721A returning number minted by OWNER
        require(_numberMinted(msg.sender) + quantity <= maxMintPerUser, "Mint limit per user");
        //totalMinted() total amount minted by the contract
        require(_totalMinted() + quantity <= maxMintSupply, "Sold out!");
       
        _safeMint(msg.sender, quantity);
        refundEndTimestamp = block.timestamp + refundPeriod;
        for(uint256 i = _currentIndex - quantity; i < _currentIndex; i++){
            refundEndTimestamps[i] = refundEndTimestamp;
        } 
    }

    function refund(uint256 tokenId) external {
        require(block.timestamp < getRefundDeadline(tokenId), "Refund period expired");
        require(msg.sender == ownerOf(tokenId), "You are not an owner of that NFT");
        uint256 refundAmount = getRefundAmount(tokenId);

        //transfer ownership of the NFT
        _transfer(msg.sender, refundAddress, tokenId);
        //mark refunded
        hasRefunded[tokenId] = true;
        //refund the price
        Address.sendValue(payable(msg.sender),refundAmount);
    
    }

    function getRefundDeadline(uint256 tokenId) public view returns(uint256) {
        if(hasRefunded[tokenId]){
            return 0;
        }
        return  refundEndTimestamps[tokenId];
    }

    function getRefundAmount(uint256 tokenId) public view returns (uint256) {
        if(hasRefunded[tokenId]){
            return 0;
        }
        return mintPrice;
    }

    function withdraw() external onlyOwner {
        //require contract owner to wait till re
        
        //fund period is end to avoid scam at very beginning
        require(block.timestamp > refundEndTimestamp, "It's not past the refund period");
        uint256 balance = address(this).balance;
        Address.sendValue(payable(msg.sender), balance);
    }
}