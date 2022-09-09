import { ethers } from "hardhat";

async function main() {
  const verifierAddress = '0xa1e1fB25268cEfB55225dbE5fD63a3b44D35E6aA';

  const Soulbound = await ethers.getContractFactory("Soulbound");
  const soulbound = await Soulbound.deploy(verifierAddress);

  await soulbound.deployed();

  console.log(`Soulbound deployed to ${soulbound.address}`);

  const Storage = await ethers.getContractFactory("Storage");
  const storage = await Storage.deploy();

  await storage.deployed();

  await storage.addSBT(soulbound.address);

  console.log(`Storage deployed to ${storage.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
