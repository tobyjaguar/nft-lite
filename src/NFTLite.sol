/** 
 *  /$$   /$$ /$$$$$$$$ /$$$$$$$$       /$$       /$$$$$$ /$$$$$$$$ /$$$$$$$$
 * | $$$ | $$| $$_____/|__  $$__/      | $$      |_  $$_/|__  $$__/| $$_____/
 * | $$$$| $$| $$         | $$         | $$        | $$     | $$   | $$      
 * | $$ $$ $$| $$$$$      | $$         | $$        | $$     | $$   | $$$$$   
 * | $$  $$$$| $$__/      | $$         | $$        | $$     | $$   | $$__/   
 * | $$\  $$$| $$         | $$         | $$        | $$     | $$   | $$      
 * | $$ \  $$| $$         | $$         | $$$$$$$$ /$$$$$$   | $$   | $$$$$$$$
 * |__/  \__/|__/         |__/         |________/|______/   |__/   |________/
 *                                                                                                                                                  
 */                                                                          

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Administered.sol";


contract NFTLite is
    Administered,
    ERC721,
    ERC721Enumerable
{
    bool public mintIsActive = true;
    uint256 public mintPrice;
    uint256 public supply;

    mapping(uint256 => string) public URIs;

    // errors
    error MintNotActive();
    error BadMintValue();

    constructor(
        uint256 _mintPrice
    )
        Administered(msg.sender)
        ERC721("Toby's NFTs", "TNFT")
    {
        mintPrice = _mintPrice;
    }

    /**
     * @dev Overrides for ERC721Enumerable.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Switches the mint from active <-> inactive.
     */
    function flipMintState() external onlyAdmin {
        mintIsActive = !mintIsActive;
    }

    /**
     * @dev   Allows owner to set the mint price dynamically.
     * @param _mintPrice The new mint price.
     */
    function setMintPrice(uint256 _mintPrice) external onlyAdmin {
        mintPrice = _mintPrice;
    }

    /**
     * @dev   Returns the URI for the given token.
     * @param tokenId The token to return the URI for.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        return URIs[tokenId];
    }

    /**
     * @dev   Mint the NFT.
     * @param _uri The universal resource identifier containing the metadata json file
     */
    function createNFT(string memory _uri) external payable {
        if (!mintIsActive) revert MintNotActive();
        if (mintPrice != msg.value) revert BadMintValue();
        uint256 mintedId = supply;
        supply = supply + 1;
        URIs[mintedId] = _uri;
        _mint(msg.sender, mintedId);
    }

    /**
     * @dev Withdraw contract's balance.
     */
    function withdrawETHBalance() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }
}