import { buildMessageMetamask, buildMessageTest, Message, SignerLike } from "./types";
import { signTypedData, SignTypedDataVersion } from "@metamask/eth-sig-util";
import { Wallet } from "ethers";

export async function prepareSignatureTest(
    rawMessage: Message, 
    signer: SignerLike, 
    verifyingContract: string
) {
    const chainId = await signer.getChainId();
    const { domain, types, message } = buildMessageTest(
        rawMessage,
        chainId,
        verifyingContract
    );
    return signer._signTypedData(domain, types, message);
}

export async function prepareSignatureMetamask(
    rawMessage: Message, 
    signer: Wallet, 
    verifyingContract: string
) {
    const chainId = await signer.getChainId();
    const params = buildMessageMetamask(
        rawMessage,
        chainId,
        verifyingContract
    );
    const callParams = {
        privateKey: Buffer.from(signer.privateKey),
        data: params,
        version: SignTypedDataVersion.V4
    }
    return signTypedData(callParams);
} 