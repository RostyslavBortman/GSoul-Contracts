import { ethers } from "hardhat";
import { expect } from "chai";
import {
  prepareSignatureMetamask,
  prepareSignatureTest,
} from "./prepareSignature";
import { Message } from "./types";
import { Wallet } from "ethers";

describe("Soulbound", function () {
  async function treasuryFixture() {
    const nonce = 0;

    const mnemonics = "exhaust short galaxy address hire cage picture water motion hold bid profit";
    const wallet = ethers.Wallet.fromMnemonic(mnemonics);
    const privateKey = wallet.privateKey.slice(2);

    const [verifier, to] = await ethers.getSigners();
    const { address: verifierAddress } = verifier;
    const { address: toAddress } = to;

    const chainId = await verifier.getChainId();

    const Soulbound = await ethers.getContractFactory("Soulbound");
    const soulbound = await Soulbound.deploy(verifierAddress, "");
    const { address: soulboundAddress } = soulbound;

    const params: Message = {
      nonce,
      verifier: verifierAddress,
      to: toAddress,
    };

    const signature = await prepareSignatureTest(
      params,
      verifier,
      soulboundAddress
    );
    
    const metamaskSignature = await prepareSignatureMetamask(
      params,
      chainId,
      privateKey,
      soulboundAddress
    );

    return { to, soulbound, params, signature, metamaskSignature };
  }

  describe("Soulbound", async () => {
    it("Should mint token", async () => {
      const { to, soulbound, params, signature } = await treasuryFixture();
      await soulbound.connect(to).mint(params, signature);

      const toBalance = await soulbound.balanceOf(to.address);
      expect(toBalance.toString()).to.equal("1");
    });

    it("Should mint token metamask", async () => {
      const { to, soulbound, params, metamaskSignature } = await treasuryFixture();

      await soulbound.connect(to).mint(params, metamaskSignature);

      const toBalance = await soulbound.balanceOf(to.address);
      expect(toBalance.toString()).to.equal("1");
    });

    it("Should produce the same signatures", async () => {
        const { signature, metamaskSignature } = await treasuryFixture();
        expect(signature).to.be.equal(metamaskSignature);
    })
  });
});
