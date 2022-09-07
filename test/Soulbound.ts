import { ethers } from "hardhat";
import { expect } from "chai";
import { prepareSignatureTest } from "./prepareSignature";
import { Message } from "./types";

describe("Soulbound", function () {
  async function treasuryFixture() {
    const nonce = 0;
    const tokenId = 2;

    const [verifier, to] = await ethers.getSigners();
    const { address: verifierAddress } = verifier;
    const { address: toAddress } = to;

    const Soulbound = await ethers.getContractFactory("Soulbound");
    const soulbound = await Soulbound.deploy(verifierAddress, "");
    const { address: soulboundAddress } = soulbound;

    const params: Message = {
      nonce,
      verifier: verifierAddress,
      to: toAddress,
      tokenId,
    };

    const signature = await prepareSignatureTest(
      params,
      verifier,
      soulboundAddress
    );

    return { to, tokenId, soulbound, params, signature };
  }

  describe("Soulbound", async () => {
    it("Should mint token", async () => {
      const {  to, soulbound, params, signature } = await treasuryFixture();
      await soulbound.connect(to).mint(params, signature);

      const toBalance = await soulbound.balanceOf(to.address);
      expect(toBalance.toString()).to.equal('1');
    });
  });
});
