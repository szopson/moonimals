// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract Moonimals is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply, PaymentSplitter {
    uint256 public publicPrice = 0.01 ether; 
    uint256 public allowListPrice = 0.001 ether; 
    uint256 public maxSupply = 10;
    uint public maxPerWallet = 3;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = true;

    mapping(address => bool) allowList;
    mapping(address => uint256) purchasesPerWallet;

    //shares should be in int as a percentage, like 10=10%
    constructor(
        address initialOwner,
        address[] memory _payees,
        uint256[] memory _shares
        )
        ERC1155("ipfs://QmRDUT4P7ac347sAC5eG8xhkm8R4Mic2eKq4uZczjQbwQL/")
        PaymentSplitter(_payees, _shares)
        Ownable(initialOwner)
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //function to edit the mint windows
    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    )   external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    //function to set the allowlist
    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint256 i=0; i<addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    //mint function for the whitelisted addresses
    function allowListMint(uint256 id, uint256 amount) public payable {
        require(allowListMintOpen, "Allow List Mint is closed");
        require(allowList[msg.sender], "You are not on the Allow List");
        require(msg.value == allowListPrice * amount);
        mint(id, amount);
    }

    //mint function for everyone else
    function publicMint( uint256 id, uint256 amount)
        public
        payable 
    {
        require(publicMintOpen, "Public List Mint is closed");
        require(msg.value == publicPrice * amount, "payment should be equal: 0.01 eth per one NFT");
        mint(id, amount);
    }

    function mint(uint256 id, uint256 amount) internal {
        require(purchasesPerWallet[msg.sender] + amount <= maxPerWallet, "Wallet mint limit reached");
        require(id < 17, "Sorry you are trying to mint id which is not available, try lower");
        require(totalSupply(id) + amount <= maxSupply, "We can't mint that much, it will exceed the total supply");
        _mint(msg.sender, id, amount,"");
        purchasesPerWallet[msg.sender] += amount;
    }

    // withdra function is not needed if we have a PaymentSplitter done
    // function withdraw(address _address) external onlyOwner{
    //     uint256 balance = address(this).balance;
    //     payable(_address).transfer(balance);
    // }

    function uri(uint256 _id) public view virtual override returns (string memory) {
        require(exists(_id), "URI: ID does not exist");
        
        // if file have an json extension we can plase "json" instead of "" in the last parameter
        return string(abi.encodePacked(super.uri(_id),Strings.toString(_id), ""));
    }


    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}