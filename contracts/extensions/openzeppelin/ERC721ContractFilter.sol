// SPDX-License-Identifier: MIT
/// @title Objective Contracts Filter ERC721 Extension (solmate)
/// @author Dean van Dugteren (https://github.com/deanpress)
/// @author Objective Contracts Filter (https://github.com/ocf-dao)
/// @notice Extends an ERC721 contract with the Objective Contracts Filter
pragma solidity ^0.8.0;

// Import this file to use console.log
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IOCF {
    function filterContract(address to) external view;

    function filterContract(address to, uint8 category) external view;

    function isOcf() external pure returns (bool);
}

abstract contract ERC721ContractFilter is ERC721 {
    uint8 internal constant CAT_VULNERABILITY = 1;
    uint8 internal constant CAT_ROYALTY = 2;

    IOCF public ocf; // Objective Contracts Filter
    bool public ocfPaused;
    uint8 public ocfCategory;

    constructor(address ocfAddress) {
        ocf = IOCF(ocfAddress);
        if (!ocf.isOcf()) revert("Not a valid OCF address");
    }

    /// @dev Filters destination address with OCF
    modifier filterContract(address to) {
        if (!ocfPaused) {
            if (ocfCategory == 0) ocf.filterContract(to);
            else ocf.filterContract(to, ocfCategory);
        }
        _;
    }

    function approve(address spender, uint256 id)
        public
        override
        filterContract(spender)
    {
        return super.approve(spender, id);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override filterContract(to) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _pauseFilter() internal virtual {
        ocfPaused = true;
    }

    function _unpauseFilter() internal virtual {
        ocfPaused = false;
    }

    function _setFilterCategory(uint8 category) internal virtual {
        ocfCategory = category;
    }
}
