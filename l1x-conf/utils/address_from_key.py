#!/usr/bin/python3

import ecdsa, codecs
from Crypto.Hash import keccak
import sys

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <private_key>")
        return

    private_key_bytes = codecs.decode(sys.argv[1], 'hex')
    # Get ECDSA public key
    key = ecdsa.SigningKey.from_string(private_key_bytes, curve=ecdsa.SECP256k1).verifying_key
    key_bytes = key.to_string()
    public_key = codecs.encode(key_bytes, 'hex')

    # print(public_key)

    public_key_bytes = codecs.decode(public_key, 'hex')
    keccak_hash = keccak.new(digest_bits=256)
    keccak_hash.update(public_key_bytes)
    keccak_digest = keccak_hash.hexdigest()

    print(keccak_digest[24:])

if __name__ == '__main__':
    main()
