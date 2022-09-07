/* eslint-disable no-process-exit */

import * as dotenv from "dotenv";

import hre from "hardhat";

dotenv.config();

async function main() {
  const erc721Boilerplate: string = ""; // CHANGE address
  const erc1155Boilerplate: string = ""; // CHANGE address

  // Verify ERC721Boilerplate
  const name: string = "ERC721Boilerplate"; // CHANGE HERE
  const symbol: string = "ERC721B"; // CHANGE HERE
  const erc721BaseURI: string =
    "https://ipfs.io/ipfs/QmdhcMjEELiEX1PqcUwAi4sQSJV6DExw27vRgfeN6hZasA?filename="; // CHANGE HERE

  try {
    await hre.run("verify:verify", {
      address: erc721Boilerplate,
      constructorArguments: [name, symbol, erc721BaseURI],
    });
  } catch (err: any) {
    console.error(err);
  }

  // Verify ERC1155Boilerplate
  const erc1155BaseURI: string =
    "https://ipfs.io/ipfs/QmdhcMjEELiEX1PqcUwAi4sQSJV6DExw27vRgfeN6hZasA?filename="; // CHANGE HERE

  try {
    await hre.run("verify:verify", {
      address: erc1155Boilerplate,
      constructorArguments: [erc1155BaseURI],
    });
  } catch (err: any) {
    console.error(err);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);

    process.exit(1);
  });
