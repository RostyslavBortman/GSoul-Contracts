import { MessageTypes, TypedMessage } from "@metamask/eth-sig-util";
import { BigNumberish } from "ethers";
import {
    TypedDataField,
    TypedDataDomain,
} from '@ethersproject/abstract-signer';

const MintType = [
    { name: 'verifier', type: 'address' },
    { name: 'to', type: 'address' },
    { name: 'tokenId', type: 'uint256' },
    { name: 'nonce', type: 'uint256' },
];

const EIP712DomainType = [
    { name: 'name', type: 'string' },
    { name: 'version', type: 'string' },
    { name: 'chainId', type: 'uint256' },
    { name: 'verifyingContract', type: 'address' },
];

export interface Message {
    verifier: string;
    to: string;
    tokenId: BigNumberish;
    nonce: BigNumberish;

}

export interface SignerLike {
    address: string;
    getChainId(): Promise<number>;
    _signTypedData(
        domain: TypedDataDomain,
        types: Record<string, Array<TypedDataField>>,
        value: Record<string, any>,
    ): Promise<string>;
}


export function buildMessageTest(
    rawMessage: Message,
    chainId: number,
    verifyingContract: string,
) {
    const { verifier, to, tokenId, nonce } = rawMessage;
    return {
        domain: {
            chainId,
            name: "Karma Token",
            verifyingContract,
            version: '1'
        },
        message: {
            verifier, to, tokenId, nonce
        },
        primaryType: 'Mint',
        types: {
            Mint: MintType,
        }
    }
}

export function buildMessageMetamask(
    rawMessage: Message,
    chainId: number,
    verifyingContract: string,
): TypedMessage<MessageTypes> {
    const params = buildMessageTest(rawMessage, chainId, verifyingContract);
    return {
        ...params,
        types: { ...params.types, EIP712Domain: EIP712DomainType },
    };
}