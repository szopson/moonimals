****Moonimals NFT project:****

*The project has 3 versions of smart contracts, NFT721, NFT1155, and NFT721A* 

**For the image generation I have used https://openart.ai/**

IPFS metadata address: ipfs://QmRDUT4P7ac347sAC5eG8xhkm8R4Mic2eKq4uZczjQbwQL/

*The NFT collection contains 17 NFTs all of which are mintable. There are two ways of minting:*
- publicMint -> anyone can mint it for 0.01 ether
- allowListMint -> only addresses from the allowList can mint it for 0.001 ether


**1)ERC721**
*Deployed on Sepolia test network*
**Deployed contract address ERC721**: 0x4cDA9319A012cDf3EfEa4D54EdaB56598CaCc6AF
https://testnets.opensea.io/collection/moonimals-1

The PaymentSplitter function has been added compared to the ERC721 contract.

**2)ERC1155**
*Deployed on Sepolia test network*
**Deployed contract address ERC1155**: 0x438Eb84ddCa3ed4F0daF6ec9c3d8BbF7686b3867
https://testnets.opensea.io/collection/unidentified-contract-e8bae6de-1fec-46ae-af6f-53ca

**3)ERC721A**
*Deployed on Sepolia test network*
**Deployed contract address ERC721**: 0x94E4eBd9b62168714aB8031B85ed5386ad77cc2F
https://testnets.opensea.io/collection/moonimal

Refund() function has been added with refundEndTimestamp where you can get back your money if you are unsatisfied 
of your NFT. That period was set to 10min for easier tests. 

There is also maxMintPerUser=4 set, each user can mint up to 4 NFTs. 

Basic onlyOwner modifier was taken from Openzeppelin Ownable contract
I have also used two contracts from exo-digital-labs to create this one, ERC721A.sol and IERC721R.sol, links below

https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/ERC721A.sol
https://github.com/exo-digital-labs/ERC721R/blob/main/contracts/IERC721R.sol

Contract has withdraw (onlyOwner) function which is limited by refundEndTimestamp period to protect potential user and give them
chance to refund within refund time.