#!/bin/bash

cat > Config/crypto.json << END
{
    "hash": {
        "method": "sha256",
        "encoding": "base64",
        "key": "$(openssl rand -base64 32)"
    },
    
    "cipher": {
        "method": "aes256",
        "encoding": "base64",
        "key": "$(openssl rand -base64 32)"
    }
}
END