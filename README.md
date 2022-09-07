# ERC721 and ERC1155 Boilerplates

## Description

Basic implementation of ERC-721 and ERC-1155 tokens. The next functionality is
implemented:

- ERC-721:

  - enumerable (adds enumerability of all the token ids in the contract as well
    as all token ids owned by each account);
  - burnable;
  - mintable (with a MINTER role). Batched minting is supported too;
  - pausable (with a PAUSER role);
  - royalties support (EIP-2981). Allows a minter to specify a royalty for each
    `tokenId` in time of minting;
  - stepped royalties - don’t send royalties if the sale price is below a
    threshold. Threshold can be set only in time of minting;
  - a receiver of royalties can be updated.

- ERC-1155

  - burnable;
  - mintable (with a MINTER role);
  - pausable (with a PAUSER role);
  - royalties support (EIP-2981). Allows a minter to specify a royalty for each
    `tokenId` in time of minting;
  - stepped royalties - don’t send royalties if the sale price is below a
    threshold. Threshold can be set only in time of minting;
  - a receiver of royalties can be updated;
  - supply.

Only an owner of contracts can add/remove a MINTER or a PAUSER.

`utils/metadata_example.json` file consist metadata example that is supported
on the OpenSea and on the Rarible.

## How to use

You can use this code in 2 different ways.

1. Choose a token contract and copy the contract's code to your repo. Also,
   don't forget to copy `access` and `erc-2981` folders with all nested
   contracts.

2. Or clone the repo and start to write your code in it.

## Testing

All contracts are covered with unit tests.

To run tests execute the next commands in your command line (terminal):

```bash
yarn start-sandbox
yarn test
```

## Compilation

To execute a compilation, you need to run the next command in your command line
(terminal):

```bash
yarn compile
```

Make shure that all your contracts are written using `0.8.4` version of
Solidity or higher.

## Migration

Before migrations update `deploy.ts` script (set proper constructor arguments)
in the `scripts` directory.

To migrate your contracts in the sandbox (to test migration files), execute the
next commands in your command line (terminal):

```bash
yarn start-sandbox
yarn migrate:sandbox
```

Also, you can migrate your contracts to the `Rinkeby` testnet. To do this,
update your `.env` file like in `.env.example` and execute the next command in
your command line (terminal):

```bash
yarn migrate:testnet
```

To add more networks support, update your `hardhat.config.ts` and
`package.json` files.

## Verification

To verify your contracts deployed to the real network, update you `.env`,
`hardhat.config.ts`, and `package.json` files. Also, you should update
verification script (`verify.ts`) that is located in the `scripts` directory.
Insert your contracts addresses and update constructor parameters. After this
execute the next commant in your command line (terminal):

```bash
yarn verify:testnet
```
