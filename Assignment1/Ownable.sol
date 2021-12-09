// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Ownable {
    address private owner;
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not owner");
        _;
    }

    function transferOwnership(address _newOwner) public {
        require(_newOwner != address(0), "Ownable: new address is null");
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }
}