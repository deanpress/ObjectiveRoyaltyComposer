// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/auth/Owned.sol";

contract ObjectiveRoyaltyComposer is Owned {
    mapping(address => bool) public isServiceFiltered;

    event ORCAddressAdded(address indexed account);
    event ORCAddressRemoved(address indexed account);

    constructor() Owned(msg.sender) {}

    // Lets the extension check for existence of the contract in the constructor
    function isORC() public pure returns (bool) {
        return true;
    }

    function addAddress(address _address) external onlyOwner {
        require(!isServiceFiltered[_address], "Contract already filtered");
        isServiceFiltered[_address] = true;
        emit ORCAddressAdded(_address);
    }

    function removeAddress(address _address) external onlyOwner {
        require(isServiceFiltered[_address], "Contract not filtered");
        isServiceFiltered[_address] = false;
        emit ORCAddressRemoved(_address);
    }
}
