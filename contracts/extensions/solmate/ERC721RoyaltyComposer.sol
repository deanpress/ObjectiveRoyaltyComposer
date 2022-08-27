// SPDX-License-Identifier: MIT
/// @title Objective Royalty Composer ERC721 Extension (solmate)
/// @author Dean van Dugteren (https://github.com/deanpress)
/// @notice Extends an ERC721 contract with the Objective Contracts Filter
pragma solidity ^0.8.0;

// Import this file to use console.log
import "solmate/src/tokens/ERC721.sol";

interface IORC {
    function filterAddress(address to) external view;

    function isORC() external pure returns (bool);

    function isServiceFiltered(address to) external view returns (bool);
}

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
}

abstract contract ERC721RoyaltyComposer is ERC721 {
    bool public orcPaused;
    IORC public orc; // Objective Contracts Filter

    uint256 public orcPremium;
    IERC20 private weth;

    address public royaltyRecipient;

    error NotEnoughWethAllowanceForPremium(uint256 allowance, uint256 required);

    constructor(address orcAddress, address wethAddress) {
        orc = IORC(orcAddress);
        weth = IERC20(wethAddress);
        royaltyRecipient = address(this);
        if (!orc.isORC()) revert("Not a valid ORC address");
    }

    /// @dev Filters destination address with ORC
    modifier filterAddress(address to) {
        if (!orcPaused) {
            orc.filterAddress(to);
        }
        _;
    }

    // Adds a WETH charge to the sender if the receiver is a contract that bypasses royalties
    function _chargePremiumIfNeeded(address to) internal {
        if (orcPremium > 0) {
            if (orc.isServiceFiltered(to)) {
                if (!weth.transferFrom(msg.sender, to, orcPremium))
                    revert NotEnoughWethAllowanceForPremium(
                        weth.allowance(msg.sender, address(this)),
                        orcPremium
                    );
            }
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual override {
        _chargePremiumIfNeeded(to);
        super.transferFrom(from, to, id);
    }

    function _pauseFilter() internal virtual {
        orcPaused = true;
    }

    function _unpauseFilter() internal virtual {
        orcPaused = false;
    }

    function _setPremium(uint256 _premium) internal virtual {
        orcPremium = _premium;
    }

    function _setRoyaltyRecipient(address _to) internal virtual {
        royaltyRecipient = _to;
    }
}
