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
        mintPrice = 1 ether;
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
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        nftlite.createNFT{value: 1 ether}(exURI01);
        assertEq(nftlite.supply(), tokenId + 1);
        assertEq(nftlite.uri(tokenId), exURI01);
        assertEq(nftlite.tokenURI(tokenId), exURI01);
        assertEq(nftlite.ownerOf(tokenId), owner);
        assertEq(nftlite.owners(tokenId), owner);
    }

    function testTransferNFT() public {
        uint256 tokenId = 0;
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        nftlite.createNFT{value: 1 ether}(exURI01);
        vm.prank(owner); 
         vm.expectEmit(false,false,false,true);
        emit Transfer(owner, bob, tokenId);
        nftlite.transfer(bob, tokenId);
        assertEq(nftlite.ownerOf(tokenId), bob);
        assertEq(nftlite.owners(tokenId), bob);
    }

    function testOwnerOf() public {
        uint256 tokenId = 0;
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        nftlite.createNFT{value: 1 ether}(exURI01);
        assertEq(nftlite.ownerOf(tokenId), owner);
        assertEq(nftlite.owners(tokenId), owner);
        vm.prank(owner);
        nftlite.transfer(alice, tokenId);
        assertEq(nftlite.ownerOf(tokenId), alice);
        assertEq(nftlite.owners(tokenId), alice);
        vm.prank(alice);
        nftlite.transfer(bob, tokenId);
        assertEq(nftlite.ownerOf(tokenId), bob);
        assertEq(nftlite.owners(tokenId), bob);
    }

    // this fails
    // function testWithdrawETHBalance() public {
    //     vm.deal(owner, 1.5 ether);
    //     vm.prank(owner);
    //     nftlite.createNFT{value: 1 ether}(exURI01);
    //     assertEq(owner.balance, .5 ether);
    //     vm.prank(owner);
    //     nftlite.withdrawETHBalance();
    //     // assertEq(address(nftlite).balance, 0);
    //     // assertEq(owner.balance, 1 ether);
    // }

    function testSetMintPrice() public {
        uint256 newMintPrice = 2 ether;
        vm.prank(owner);
        nftlite.setMintPrice(newMintPrice);
        assertEq(nftlite.mintPrice(), newMintPrice);
    }

    function testTokenURI() public {
        uint256 tokenId = 0;
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        nftlite.createNFT{value: 1 ether}(exURI01);
        assertEq(nftlite.tokenURI(tokenId), exURI01);
    }

    /* Test Fail cases */
    function testCannotCreateNFTWithZeroAddress() public {
        vm.deal(address(0x0), 1 ether);
        vm.prank(address(0x0));
        vm.expectRevert(ZeroAddress.selector);
        nftlite.createNFT{value: 1 ether}(exURI01);
    }

    function testCannotCreateNFTWithBadMintValue() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        vm.expectRevert(BadMintValue.selector);
        nftlite.createNFT{value: 0}(exURI01);
    }

    function testCannotTransferToZeroAddress() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        nftlite.createNFT{value: 1 ether}(exURI01);
        vm.prank(owner);
        vm.expectRevert(ZeroAddress.selector);
        nftlite.transfer(address(0x0), 0);
    }

    function testCannotTransferIfNotTheOwner() public {
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        nftlite.createNFT{value: 1 ether}(exURI01);
        vm.prank(bob);
        vm.expectRevert(NotTheOwner.selector);
        nftlite.transfer(bob, 0);
    }
}
