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

    function isAddressOrced(address to) external view returns (bool);
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
    IORC public orc; // Objective Royalty Composer

    uint256 public orcPremium;
    IERC20 private weth;

    struct PremiumData {
        uint256 latestUpdateTime;
        uint64 minInterval;
        uint64 maxIncreasePercent;
    }

    PremiumData public premiumData;

    address public royaltyRecipient;

    error NotEnoughWethAllowanceForPremium(uint256 allowance, uint256 required);

    constructor(
        address orcAddress,
        address wethAddress,
        uint256 premium,
        uint64 minInterval,
        uint64 maxIncreasePercent
    ) {
        orc = IORC(orcAddress);
        weth = IERC20(wethAddress);
        royaltyRecipient = address(this);
        orcPremium = premium;
        premiumData = PremiumData(minInterval, maxIncreasePercent, 0);
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
        // Nested if statements save gas
        if (orcPremium > 0) {
            if (orc.isAddressOrced(to)) {
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
        // Only allow orcPremium to update if the timestamp is greater than the latestIncreaseTime + minInterval
        if (
            block.timestamp >
            premiumData.latestUpdateTime + premiumData.minInterval
        ) {
            // Check that _premium is not greater than the max increase percentage for orcPremium
            if (
                _premium <=
                orcPremium +
                    ((orcPremium * 1 ether) * premiumData.maxIncreasePercent) /
                    100 /
                    1 ether
            ) {
                orcPremium = _premium;
                premiumData.latestUpdateTime = block.timestamp;
            } else {
                revert("ORC: Premium is greater than the max allowed increase");
            }
        } else {
            revert("ORC: Premium update interval has not been reached");
        }
    }

    function _setRoyaltyRecipient(address _to) internal virtual {
        royaltyRecipient = _to;
    }
}
