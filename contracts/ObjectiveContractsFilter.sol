// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solmate/src/auth/Owned.sol";

contract ObjectiveContractsFilter is Owned {
    uint8 private constant CAT_VULNERABILITY = 1;
    uint8 private constant CAT_ROYALTY = 2;

    mapping(address => uint8) public blockedContracts;

    event OCFContractAdded(address indexed account, uint8 category);
    event OCFContractRemoved(address indexed account, uint8 category);

    error OCFContractBlocked(address, uint8 category);

    constructor() Owned(msg.sender) {}

    // Lets the extension check for existence of the contract in the constructor
    function isOcf() public pure returns (bool) {
        return true;
    }

    function addContract(address _contract, uint8 category) external onlyOwner {
        require(category == CAT_VULNERABILITY || category == CAT_ROYALTY);
        blockedContracts[_contract] = category;
        emit OCFContractAdded(_contract, category);
    }

    function removeContract(address _contract) external onlyOwner {
        blockedContracts[_contract] = 0;
        emit OCFContractRemoved(_contract, blockedContracts[_contract]);
    }

    function filterContract(address to) external view {
        uint8 category = blockedContracts[to];
        if (category != 0) revert OCFContractBlocked(to, category);
    }

    function filterContract(address to, uint8 category) external view {
        if (blockedContracts[to] == category)
            revert OCFContractBlocked(to, category);
    }
}
