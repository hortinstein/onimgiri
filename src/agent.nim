import asyncdispatch, asyncnet
import sysrandom

#third party libraries
import puppy #http comms library
import monocypher
import flatty

echo fetch("http://neverssl.com/")


let a_secretKey = getRandomBytes(sizeof(Key))
let a_publicKey = crypto_key_exchange_public_key(a_secretKey)

let b_secretKey = getRandomBytes(sizeof(Key))
let b_publicKey = crypto_key_exchange_public_key(b_secretKey)

let a_sharedKey = crypto_key_exchange(a_secretKey, b_publicKey)
let b_sharedKey = crypto_key_exchange(b_secretKey, a_publicKey)

doAssert(a_sharedKey == b_sharedKey)