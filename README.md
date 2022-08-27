# Objective Contract Filter DAO

**An ERC721/ERC20/ERC1155 contract extension that prevents transfers to NFT royalty bypassers and critically insecure smart contracts.**

*Note: a contract for this DAO is not live. It is a proof of concept. This repository currently serves for educational and demonstration purposes. There have been a lot of [discussions](https://github.com/chiru-labs/ERC721A/issues/416) recently regarding possible solutions for NFT royalty bypassing protocols, and this smart contract serves to demonstrate a possible solution.*

## How it works

OCF is a public good DAO that protects a token contract's users from transferring tokens to known critically insecure smart contracts, and protects NFT collection creators from contracts that bypass the NFT standard royalty system.

When you add this extension to your ERC20, ERC721, or ERC1155 contract, all `transferFrom` and `approve` (and for ERC20 `transfer`) calls will query the destination address in the OCF contract and will revert the transaction if there's a match.

## Quick start

1. Add the relevant extension to your ERC721 base contract:
   * [Solmate ERC721](./contracts/extensions/solmate/ERC721ContractFilter.sol)
   * [Openzeppelin ERC721](contracts/extensions/openzeppelin/ERC721ContractFilter.sol)

2. **Optional (recommended)**: implement admin-only functions that call `_pauseFilter()` and `_unpauseFilter()` to disable/enable the contract filter. The filter is enabled by default.
  
3. **Optional**: in your contract constructor call `_setFilterCategory(uint8)` with `CAT_VULNERABILITY` or `CAT_ROYALTY` to filter destination addresses for a specific category (e.g. *only* royalty bypassers). All categories are used by default (uint8 argument `0`). Checking for a single category does not save gas, so if there's no reason for your contract to exclude a specific category from the filter, don't set the category.
  
## Why?

NFT trading royalties cannot not be enforced within NFT contracts without requiring payments for *every* type of transfer (including outgoing non-trade transactions). Doing this would be user-unfriendly, which is why NFT royalty rates are only a viewable number within an NFT contract, and NFT trading protocols are expected, but not enforced, to honor these royalties. This is for the sake of making NFT interactions as easy as possible for end-users, but ends up being abused by protocols that act in bad faith.

More bad faith protocols and marketplaces are being deployed that circumvent/exploit this royalty system by re-delegating royalty fees to themselves instead of the NFT creator.

This DAO's original purpose is to provide ERC721 and ERC1155 contracts with a filter that can prevent transfers and approvals to protocols that do this, to ensure the current accessible NFT royalty system remains working as intended.

The consideration alone of this DAO being integrated in some NFT collections should be enough for most serious protocols to support the current royalty system. Therefore, OCF's mere existence will already help in maintaining good faith among protocols in the ecosystem.

Since this contract is simply an address list governed by a multisig wallet of independent projects, an additional helpful use case would be to also include entries for critically insecure smart contracts that were publicly proven to have critical security flaws that can drain/steal user assets.

## What addresses are filtered

The DAO is *only* expected to maintain *smart contract* addresses in the filter.

Furthermore, any of the below points should apply to a filtered contract:

* Category 1: The contract can execute exchanges of ERC721 or ERC1155 assets while **bypassing the royalties standard**.

* Category 2: The contract has a **severe security vulnerability** that can be exploited (by any party, including the contract owner) in a way that causes user deposits to be lost or stolen.

Either of the above points *must* be *objectively proven* with a short, written report that includes: snippets of the smart contract code (in the case of an open-source contract), or a transaction log, or a test suite simulation (e.g. a hardhat test) that proves the offense. A proposal should never be made or approved if it hasn't been proven to match any of the above points. See [proposal guidelines](#proposal-guidelines).

Smart contracts can choose to filter addresses for a single category, or both categories.

## What contract are *not* filtered

This DAO only exists for the purpose of serving external smart contract functions that revert when outgoing asset transfers are made to objectively critically insecure smart contract and ERC721/ERC1155 royalty-bypassers.

This DAO will *not* consider or propose anything that does not apply to the above.

It is *not* within the scope or responsibility of this DAO to add addresses based on any other guidelines.

## Proposal guidelines

Address filter proposals should always be publicly available before receiving multisig approval.

* Proposals **should** be made if: the proposed contract's exploit is already public, or if the contract bypasses NFT trading royalties.

* Proposals **should not** be made (or discussed at all) if: there are pre-existing deposits in the contract that are directly put at risk by the publishing of the proposal, unless any such exploit has already been made public.

It is not within the scope of this DAO to discover and combat security vulnerabilities in smart contracts. OCF only lists contracts that are publicly known to have critical security flaws that put assets at risk, or circumvent NFT trading royalties.

Contract addresses can also be removed from the filter i.e. in the case of upgradeable proxy contracts, where a contract was upgraded to fix a security vulnerability or royalty circumvention.

## Governance

OCF is operated by a multisig wallet consisting of several reputable independent smart contract projects and developers. Proposals can only be voted on by multisig participants.

Adding or removing a contract address from the filter requires a 60% approval from the multisig participants (with fractional thresholds rounded up e.g. 60% of 17 = 10.2 = 11/17).
