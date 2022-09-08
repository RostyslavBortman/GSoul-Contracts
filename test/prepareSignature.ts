import { buildMessageMetamask, buildMessageTest, Message, SignerLike } from "./types";
import { signTypedData, SignTypedDataVersion } from "@metamask/eth-sig-util";

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
    chainId: number,
    privateKey: string,
    verifyingContract: string
) {
    const params = buildMessageMetamask(
        rawMessage,
        chainId,
        verifyingContract
    );
    const bufferFrom = Buffer.from(privateKey, "hex");
    const callParams = {
        privateKey: bufferFrom,
        data: params,
        version: SignTypedDataVersion.V4
    }
    return signTypedData(callParams);
} 