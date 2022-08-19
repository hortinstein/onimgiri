import unittest
import protocol
import monocypher
import sysrandom

let a_secretKey = getRandomBytes(sizeof(Key))
let a_publicKey = crypto_key_exchange_public_key(a_secretKey)

let b_secretKey = getRandomBytes(sizeof(Key))
let b_publicKey = crypto_key_exchange_public_key(b_secretKey)
let plaintext = cast[seq[byte]]("hello this is a test string")
  
test "testing that messages can be enc then dec":
  let encMsg = encMsg(a_secretKey,b_publicKey,plaintext)
  let decMsg = decMsg(b_secretKey,encMsg)
  doAssert(plaintext == decMsg)

test "testing enc, serialize, deserialize, dec":
  let encMsg = encMsg(a_secretKey,b_publicKey,plaintext)
  let serEncMsg = serEncMsg(encMsg)
  let deSerEncMsg = desEncMsg(serEncMsg)
  let decMsg = decMsg(b_secretKey,deSerEncMsg)
  doAssert(plaintext == decMsg)

test "testing base64,enc, serialize, deserialize, dec, unbase64":
  let encMsg = encMsg(a_secretKey,b_publicKey,plaintext)
  let serEncMsg = serEncMsg(encMsg)
  let base64SerEncMsg = base64Str(serEncMsg)
  let unbase64SerEncMsg = unbase64Str(base64SerEncMsg)
  let deSerEncMsg = desEncMsg(unbase64SerEncMsg)
  let ptext = decMsg(b_secretKey,deSerEncMsg)
  doAssert(plaintext == ptext)