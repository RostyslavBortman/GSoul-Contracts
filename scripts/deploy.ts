import { Contract, ContractFactory } from "ethers";

import { ethers } from "hardhat";

async function main() {
  /**
   * ERC721Boilerplate
   */
  const name: string = "ERC721Boilerplate"; // CHANGE HERE
  const symbol: string = "ERC721B"; // CHANGE HERE
  const erc721BaseURI: string =
    "https://ipfs.io/ipfs/QmdhcMjEELiEX1PqcUwAi4sQSJV6DExw27vRgfeN6hZasA?filename="; // CHANGE HERE
  const ERC721Boilerplate: ContractFactory = await ethers.getContractFactory(
    "ERC721Boilerplate"
  );
  const erc721Boilerplate: Contract = await ERC721Boilerplate.deploy(
    name,
    symbol,
    erc721BaseURI
  );

  await erc721Boilerplate.deployed();

  console.log("ERC721Boilerplate: ", erc721Boilerplate.address);

  /**
   * ERC1155Boilerplate
   */
  const erc1155BaseURI: string =
    "https://ipfs.io/ipfs/QmdhcMjEELiEX1PqcUwAi4sQSJV6DExw27vRgfeN6hZasA?filename="; // CHANGE HERE
  const ERC1155Boilerplate: ContractFactory = await ethers.getContractFactory(
    "ERC1155Boilerplate"
  );
  const erc1155Boilerplate: Contract = await ERC1155Boilerplate.deploy(
    erc1155BaseURI
  );

  await erc1155Boilerplate.deployed();

  console.log("ERC1155Boilerplate: ", erc1155Boilerplate.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
