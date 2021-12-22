// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721Receiver.sol";
import "./ERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./Strings.sol";
import "./Address.sol";

contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Strings for uint;
    using Address for address;

    string private name_;   
    string private symbol_; 

    // Mapping from token ID to owner address
    mapping(uint256 => address) private owners;

    // Mapping owner address to token count
    mapping(address => uint256) private balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;

    // Mapping from owner to operator(spender) approvals
    mapping(address => mapping(address => bool)) private operatorApprovals;

    // BaseURI
    string public baseURI;
 
    // Events are already defined in Interface721

    constructor(string memory _name, string memory _symbol) {
        name_ = _name;
        symbol_ = _symbol;
    }


    /* ---------------------------------------------- 
                Mandatory Functions
       ---------------------------------------------- */
    /// For Overriding from Interface, Name, Input Parameters and return type should be same 
    function balanceOf(address _owner) public view override returns (uint256) {
        require(_owner != address(0), "ERC721: balance query for the zero address");
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view override returns (address) {
        address owner = owners[_tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function approve(address _to, uint256 _tokenId) public override {
        address owner = ownerOf(_tokenId);
        require(_to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");

        _approve(_to, _tokenId);
    }

    // Returns address which has specific token approval
    function getApproved(uint256 _tokenId) public view override returns (address) {
        require(_exists(_tokenId), "ERC721: Approved query for nonexistent token");
        return tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) public override {
        require(msg.sender != _operator, "ERC721: approve to caller");
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view override returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
         require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
         _transfer(_from, _to, _tokenId);
    }

     function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    /* ---------------------------------------------- 
                Metadata Functions(IERC721Metadata)
    // ---------------------------------------------- */

    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() public view override returns (string memory) {
        return name_;
    }

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() public view override returns (string memory) {
        return symbol_;
    }

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. 
    /// The URI may point to a JSON file that conforms to the "ERC721 Metadata JSON Schema".
    /// Metadata.json of a token may have name, description, image, attributes etc of a token
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC721: URI query for nonexistent token");
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json")) : "";
    }

    // Helper
    function setBaseURI(string memory _baseURI) internal {
        require(bytes(_baseURI).length > 0, "ERC721: Cannot set empty baseURI");
        baseURI = _baseURI;
    }

    /* ---------------------------------------------- 
                Internal Transfer Functions
    // ---------------------------------------------- */
    function _transfer(address _from, address _to, uint256 _tokenId) internal  {
        require(ownerOf(_tokenId) == _from, "ERC721: transfer from incorrect owner");
        require(_to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), _tokenId);

        balances[_from] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _approve(address _to, uint256 _tokenId) internal {
        tokenApprovals[_tokenId] = _to;
        emit Approval(ownerOf(_tokenId), _to, _tokenId);
    }

    /* ---------------------------------------------- 
                Internal Extra Functions
    // ---------------------------------------------- */

       function _safeMint(address _to, uint256 _tokenId) internal {
            _safeMint(_to, _tokenId, "");
    }
    
    function _safeMint(address _to, uint256 _tokenId, bytes memory _data) internal {
        _mint(_to, _tokenId);
        require(_checkOnERC721Received(address(0), _to, _tokenId, _data),"ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0), "ERC721: mint to the zero address");
        require(!_exists(_tokenId), "ERC721: token already minted");

        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);
    }

    function _burn(uint256 _tokenId) internal {
        address owner = ownerOf(_tokenId);

        // Clear approvals
        approve(address(0), _tokenId);

        balances[owner] -= 1;
        delete owners[_tokenId];

        emit Transfer(owner, address(0), _tokenId);
    }



    /* ---------------------------------------------- 
                Helper Functions
    // ---------------------------------------------- */
    function _exists(uint _tokenId) public view returns(bool) {
        return owners[_tokenId] != address(0);
    }

      function _isApprovedOrOwner(address _spender, uint256 _tokenId) public view returns (bool) {
        require(_exists(_tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(_tokenId);
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }


    /* ---------------------------------------------- 
                Miscellaneous Functions
       ---------------------------------------------- */
/// Note: the ERC-165 identifier for this interface is 0x80ac58cd

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _checkOnERC721Received(address _from,address _to,uint256 _tokenId,bytes memory _data) private returns (bool) {
        if (_to.isContract()) {
            try IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
