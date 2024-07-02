// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Moonimals is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 constant public maxSupply = 100;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool) private allowList;

    constructor(address initialOwner)
        ERC721("Moonimals", "ANM")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmRDUT4P7ac347sAC5eG8xhkm8R4Mic2eKq4uZczjQbwQL/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows (bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    //Add payment
    //Add limiting of supply
    function publicMint() public payable  {        
        require(publicMintOpen, "Public mint closed");
        require(msg.value == 0.01 ether, "Funds needed for mint are 0.01 ether");
        mintCheck();
    }

    //Add payment
    //Add limiting of supply
    function allowListMint() public payable  {
        require(allowList[msg.sender], "You are not on the allow list");
        require(allowListMintOpen, "Allow list mint closed");
        require(msg.value == 0.001 ether, "Funds needed for mint are 0.001 ether");
        mintCheck();
    }

    function mintCheck() internal {
        require(totalSupply() < maxSupply, "We sold out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _address) external onlyOwner {
        //get the balance of the contract
        uint256 balance = address(this).balance;
        payable(_address).transfer(balance);
    }
    //populate the allowList
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }
    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
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