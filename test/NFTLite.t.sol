// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFTLite.sol";

contract NFTLiteTest is Test {
    NFTLite public nftlite;
    string public name;
    string public symbol;

    uint256 public mintPrice;
    uint256 public uintZero = 0;

    address public owner;
    address public alice;
    address public bob;

    string public exURI01 = "https://ipfs.test/01";
    string public exURI02 = "https://ipfs.test/02";
    
    // events
    event Transfer(address from, address to, uint256 tokenId);

    // errors
    error ZeroAddress();
    error BadMintValue();
    error NotTheOwner();

    function setUp() public {
        name = "NFTLite";
        symbol = "NFTL";
        mintPrice = 1_000_000_000_000_000_000;
        owner = address(0x1);
        alice = address(0x2);
        bob = address(0x3);
        vm.prank(owner);
        nftlite = new NFTLite(name, symbol, mintPrice);
    }

    function testGlobalVars() public {
        assertEq(nftlite.owner(), owner);
        assertEq(nftlite.name(), name);
        assertEq(nftlite.symbol(), symbol);
        assertEq(nftlite.mintPrice(), mintPrice);
        assertEq(nftlite.supply(), uintZero);
    }

    function testCreateNFT() public {
        uint256 tokenId = 0;
        vm.deal(alice, 1 ether);
        vm.prank(alice);
        nftlite.createNFT{value: 1 ether}(exURI01);
        assertEq(nftlite.supply(), tokenId + 1);
        assertEq(nftlite.uri(tokenId), exURI01);
        assertEq(nftlite.tokenURI(tokenId), exURI01);
        assertEq(nftlite.ownerOf(tokenId), alice);
        assertEq(nftlite.owners(tokenId), alice);
    }
}
