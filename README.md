# Vault contract

## Description

This project is an implementation of a contract that helps users deposit `Eth` and receive unmovable `shares` in return at a fixed rate and then be able to burn those ‘shares’ for ‘x’ erc20 tokens available from the ‘vault’ stored in the contract at that given time, determined prorate.

## Use cases

- User can deposit `eth` into the contract, the contract generates and assigns ‘x1’ amount of shares to the user address in return at a predetermined rate.
- User can redeem his tokens, the amount depends on the percentage of shares he holds and the total tokens available.
- User can know how much shares he's holding at any time.
- Top 10 users holding the largest amount of shares.
- Total amount of `eth` deposited as well as Total shares.
- Vault ERC20 token can be set by the owner and only once.
