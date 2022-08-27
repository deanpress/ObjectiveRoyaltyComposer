// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/auth/Owned.sol";

contract ObjectiveRoyaltyComposer is Owned {
    // If an address returns true here then it's a royalty bypassing service.
    mapping(address => bool) public isAddressOrced;

    event Orced(address indexed account);
    event Unorced(address indexed account);

    constructor() Owned(msg.sender) {}

    // Lets the extension check for existence of the contract in the constructor
    function isORC() public pure returns (bool) {
        return true;
    }

    // Add an address to the ORC list
    function orc(address _address) external onlyOwner {
        require(!isAddressOrced[_address], "Contract already orced");
        isAddressOrced[_address] = true;
        emit Orced(_address);
    }

    // Remove an address from the ORC list
    function unorc(address _address) external onlyOwner {
        require(isAddressOrced[_address], "Contract not orced");
        isAddressOrced[_address] = false;
        emit Unorced(_address);
    }
}
