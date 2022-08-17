# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import monocypher
import sysrandom

echo("key size: ", sizeof(Key))
echo("nonce size: ", sizeof(Nonce))
let a_secretKey = getRandomBytes(sizeof(Key))
let a_publicKey = crypto_key_exchange_public_key(a_secretKey)

let b_secretKey = getRandomBytes(sizeof(Key))
let b_publicKey = crypto_key_exchange_public_key(b_secretKey)

test "key exchange works":
  let a_sharedKey = crypto_key_exchange(a_secretKey, b_publicKey)
  let b_sharedKey = crypto_key_exchange(b_secretKey, a_publicKey)
  doAssert(a_sharedKey == b_sharedKey)

test "encryption works":  
  let sharedKey = crypto_key_exchange(a_secretKey, b_publicKey)

  let nonce = getRandomBytes(sizeof(Nonce))
  let plaintext = cast[seq[byte]]("hello")
  let (mac, ciphertext) = crypto_lock(sharedKey, nonce, plaintext)
  let decrypted = crypto_unlock(sharedKey, nonce, mac, ciphertext)

