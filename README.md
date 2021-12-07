# Blockchain coding assignments

This document will cover four weeks(1 month) coding assignments, the assignments will focus mainly on Ethereum, solidity, web3 based development. At the end of each assignment, your code will be reviewed by a senior developer. 

> Note: Write your code while using solidity latest version (currently 0.8.9)

## Assignment # 1:
Create a custom erc20 token with the following details:
1. Token name: TroonToken
2. Token symbol: TRN
3. Decimal: 8
4. Max supply: 20 million

The token contract should use the safeMath library for all the arithmetic operations. The contract should be ownable and only the owner can mint new tokens. 

**Helping Material**
| Item | Link |
| ------ | ------ |
| ERC-20 standard official documentation | https://eips.ethereum.org/EIPS/eip-20 |
| Implementation example | https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20.sol |

> Note: Deploy the token contract on Rinkeby testnet and test all methods using Metamask wallet. 


## Assignment # 2:
**Problem Statment:**
    Create a smart contract to sell NFTs. The total number of NFTs available will be 100 and each NFT costs 0.5 Ethers. A single user can not buy more than 10 NFTs.  All of the collected ETH tokens should be transferred to the admin wallet. 

**Additional Information**
1. Use ERC721 standard to create NFTs.
2. Use reentrancy guard on the payable functions. 
3. Contract should be ownable.
4. Use random images for NFT.
5. Use ipfs (pinata) for storing NFT metadata.

**Helping Material**
| Item | Link |
| ------ | ------ |
| ERC-721 standard official documentation | https://eips.ethereum.org/EIPS/eip-721 |
| NFT contract example | https://github.com/ProjectOpenSea/opensea-creatures/blob/master/contracts/ERC1155Tradable.sol |
| Metadata standard | https://docs.opensea.io/docs/metadata-standards |

> Note: Deploy the token contract on Rinkeby testnet and test all methods using Metamask wallet. 

