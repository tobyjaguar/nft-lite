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
// optimization at 200 runs


contract NFTLite
{
    address public owner;
    string public name;
    string public symbol;
    uint256 public supply;
    uint256 public mintPrice;

    mapping(uint256 => address) public owners;
    mapping(uint256 => string) public uri;

    // events
    event Transfer(address from, address to, uint256 tokenId);

    // errors
    error ZeroAddress();
    error BadMintValue();
    error NotTheOwner();

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _mintPrice
    )
    {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        mintPrice = _mintPrice;
    }

    /**
     * @dev   Allows owner to set the mint price dynamically.
     * @param _mintPrice The new mint price.
     */
    function setMintPrice(uint256 _mintPrice) external {
        if (msg.sender != owner) revert NotTheOwner();
        mintPrice = _mintPrice;
    }

    /**
     * @dev   Returns the URI for the given token.
     * @param _tokenId The token to return the URI for.
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        return uri[_tokenId];
    }

    /**
     * @dev   Mint the NFT.
     * @param _uri The universal resource identifier containing the metadata json file
     */
    function createNFT(string memory _uri) external payable {
        if (msg.sender == address(0)) revert ZeroAddress();
        if (mintPrice != msg.value) revert BadMintValue();
        if (msg.sender != owner) revert NotTheOwner();
        uint256 mintedId = supply;
        supply = supply + 1;
        uri[mintedId] = _uri;
        owners[mintedId] = msg.sender;
        emit Transfer(address(0), msg.sender, mintedId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _tokenId) external {
        if (msg.sender != ownerOf(_tokenId)) revert NotTheOwner();
        if (_to == address(0)) revert ZeroAddress();
        owners[_tokenId] = _to;
        emit Transfer(msg.sender, _to, _tokenId);
    }

    /** 
     * @dev Returns the owner of the `tokenId`.
     */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        return owners[_tokenId];
    }

    /**
     * @dev Withdraw contract's balance.
     */
    function withdrawETHBalance() external {
        if (msg.sender != owner) revert NotTheOwner();
        payable(msg.sender).transfer(address(this).balance);
    }
}