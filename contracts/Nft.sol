//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Nft is ERC721URIStorage {

    event NftMint(address _owner, uint256 _id);


    uint256 tokenCounter;
    address owner;
    mapping(address => uint256[]) collectionOf;
    
    constructor () ERC721("Guibraguini Nft", "GBN"){
        tokenCounter = 0;
        owner = msg.sender;
    }

    function createCollectible(string memory tokenURI) public returns (uint256) {
        
        tokenCounter = tokenCounter + 1;
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        emit NftMint(msg.sender, newItemId);
        collectionOf[msg.sender].push(newItemId);
        return newItemId;
    }

    function deleteCollection(uint256 ownerNftId) private {
        uint256[] memory check = collectionOf[msg.sender];
        for (uint i = 0; i < check.length; i++){
            if(check[i] == ownerNftId){
                if(i != check.length - 1){
                    collectionOf[msg.sender][i] = collectionOf[msg.sender][check.length - 1];
                }
                collectionOf[msg.sender].pop();
            }
        }
    }

    function transferNft(uint256 ownerNftId, address newOwner) public {
        safeTransferFrom(msg.sender, newOwner, ownerNftId);
        deleteCollection(ownerNftId);
        collectionOf[newOwner].push(ownerNftId);
    }

    function getCollection()public view returns( uint256  [] memory){
        return collectionOf[msg.sender];
    }

    function isOwner(address _address, uint256 nftid) public view returns (uint16) {
        if(_address == ownerOf(nftid)){
            return 1;
        }
        return 0;
    }
}

contract NftOwnership is ERC721URIStorage{

    event ownershipMint(address _owner, uint256 _id);

    uint256 owners;
    address owner;
    mapping(address => uint256[]) collectionOf;
    
    constructor () ERC721("Guibraguini Nft Ownership", "GBNO"){
        owner = msg.sender;
        owners = 0;
    }

    function mintOwnership(string memory tokenURI, uint256 ownerNftId) public returns(uint256){
        if(owners == 0){
            require(msg.sender == owner, "Not owner");
        }
        else{
            require(msg.sender == ownerOf(ownerNftId), "Not owner");
        }
        
        owners = owners + 1;
        uint256 newItemId = owners;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        emit ownershipMint(msg.sender, newItemId);
        collectionOf[msg.sender].push(newItemId);
        return newItemId;
    }

    function deleteCollection(uint256 ownerNftId) private {
        uint256[] memory check = collectionOf[msg.sender];
        for (uint i = 0; i < check.length; i++){
            if(check[i] == ownerNftId){
                if(i != check.length - 1){
                    collectionOf[msg.sender][i] = collectionOf[msg.sender][check.length - 1];
                }
                collectionOf[msg.sender].pop();
            }
        }
    }

    function transferOwnership(uint256 ownerNftId, address newOwner) public {
        safeTransferFrom(msg.sender, newOwner, ownerNftId);
        deleteCollection(ownerNftId);
        collectionOf[newOwner].push(ownerNftId);
    }

    function getCollection()public view returns( uint256 [] memory){
        return collectionOf[msg.sender];
    }

    function isOwner(address _address, uint256 nftid) public view returns (uint16) {
        if(_address == ownerOf(nftid)){
            return 1;
        }
        return 0;
    }
}