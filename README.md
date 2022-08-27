# Objective Royalty Composer

**An ERC721 standard extension that charges senders a premium fee when NFTs are sent to known royalty bypassing services.**

*Note: a contract for this DAO is not live. It is a proof of concept. This repository currently serves for educational and demonstration purposes. There have been a lot of [discussions](https://github.com/chiru-labs/ERC721A/issues/416) recently regarding possible solutions for NFT royalty bypassing protocols, and this smart contract serves to demonstrate a possible solution.*

## How it works

ORC is a DAO and ERC721 extension that adds a premium WETH charge for senders if sending an NFT to a services that aims to bypass the NFT standard royalty system. This way the NFT creator will receive a fee that's representative of foreseen loss of exchange royalties, while still allowing their NFTs to be transfered anywhere.

When you add this extension to your ERC721 contract, all `transferFrom` contract calls will query the destination address in the ORC contract, and, if there's a match, the NFT-configured `orcPremium` amount of WETH will be transfered from the sender to the NFT's configured royalty receiver.

The NFT owner must have approved the NFT contract to spend the `orcPremium` WETH amount beforchand, or the transaction will revert.

## Quick start

1. Add the relevant extension to your ERC721 base contract:
   * [Solmate ERC721](./contracts/extensions/solmate/ERC721RoyaltyComposer.sol)
   * [Openzeppelin ERC721](contracts/extensions/openzeppelin/ERC721RoyaltyComposer.sol)

2. Add the contract extension to your main contract and set the constructor arguments.

3. **Optional:** If you want to adjust the premium, implement the `_setPremium` function in an external (owner-only) function. This function lets you update the premium but only after the constructor-configured interval has passed, and if the new amount is not greater than the constructor-configured increase percentage. This gives a guarantee to holders of the NFT that the premium amount cannot suddenly spike and will only change within preset boundaries.

4. **Optional (recommended)**: implement admin-only functions that call `_pauseFilter()` and `_unpauseFilter()` to disable/enable the DAO-operated ORC address list. The list is enabled by default.
  
## Why?

NFT trading royalties cannot not be enforced within NFT contracts without requiring payments for *every* type of transfer (including outgoing non-trade transactions). Doing this would be user-unfriendly, which is why NFT royalty rates are only a viewable number within an NFT contract. NFT trading protocols are expected, but not enforced, to honor these royalties. This is for the sake of making NFT interactions as easy as possible for end-users. Unfortunately, this system is being abused by protocols that act in bad faith.

More bad faith protocols and marketplaces are being deployed that exploit this royalty system by re-delegating royalty fees to themselves instead of the NFT creator.

This DAO's purpose is to provide ERC721 contracts with a system that can charge the sender a premium when NFTs are sent to services that do this, to ensure the NFT creators are still compensated while also still permitting transfers to all destinations.

The consideration alone of this system being integrated into some NFT collections should be enough for most serious protocols to support the current royalty system. Thereforc, ORC's mere existence will already help in maintaining good faith among protocols in the ecosystem.

## What addresses are filtered

ORC is *only intended* to maintain a list of addresses that **bypass the royalties standard**.

This *must* be *objectively proven* with a short, written report that includes: snippets of the smart contract code (in the case of an open-source contract) or a recording of a reproducable exchange flow, or a transaction log, or a test suite simulation (e.g. a hardhat test) that proves the offense. A proposal should never be made or approved if it hasn't been proven to match the above requirements.

Addresses can also be removed from the filter i.e. in the case of upgradeable proxy contracts, where a contract was upgraded to fix a security vulnerability or royalty circumvention.

## What addresses are *not* filtered

This DAO only exists for the purpose of maintaining a public mapping of ERC721/ERC1155 royalty-bypassers.

This DAO will *not* consider or propose anything that does not apply to the above.

It is *not* within the scope or responsibility of this DAO to add addresses based on any other guidelines.

## Governance

ORC is operated by a multisig wallet consisting of several reputable independent smart contract projects and developers. Proposals can only be voted on by multisig participants.

Adding or removing a contract address from the filter requires a 60% approval from the multisig participants (with fractional thresholds rounded up e.g. 60% of 17 = 10.2 = 11/17).
