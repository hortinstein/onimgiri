import configjs
import unittest
import protocol
import monocypher
import sysrandom
import types
import tasks

let a_secretKey = getRandomBytes(sizeof(Key))
let a_publicKey = crypto_key_exchange_public_key(a_secretKey)

let b_secretKey = getRandomBytes(sizeof(Key))
let b_publicKey = crypto_key_exchange_public_key(b_secretKey)
let plaintext = cast[seq[byte]]("hello this is a test string")
  
test "testing that messages can be enc then dec":
  let encMsg = encMsg(a_secretKey,b_publicKey,plaintext)
  let decMsg = decMsg(b_secretKey,encMsg)
  doAssert(plaintext == decMsg)

test "testing that messages fail on bad keys":
  let encMsg = encMsg(a_secretKey,b_publicKey,plaintext)
  try:
    let decMsg = decMsg(getRandomBytes(sizeof(Key)),encMsg)
    doAssert(plaintext == decMsg)
  except IOError:
    echo "failed the decryption test"
  
test "testing enc, serialize, deserialize, dec":
  let encMsg = encMsg(a_secretKey,b_publicKey,plaintext)
  let serEncMsg = serEncMsg(encMsg)
  let deSerEncMsg = desEncMsg(serEncMsg)
  let decMsg = decMsg(b_secretKey,deSerEncMsg)
  doAssert(plaintext == decMsg)

test "testing base64,enc, serialize, deserialize, dec, unbase64":
  let encMsg = encMsg(a_secretKey,b_publicKey,plaintext)
  let serEncMsg = serEncMsg(encMsg)
  let base64SerEncMsg = b64Str(serEncMsg)
  let unbase64SerEncMsg = unb64Str(base64SerEncMsg)
  let deSerEncMsg = desEncMsg(unbase64SerEncMsg)
  let ptext = decMsg(b_secretKey,deSerEncMsg)
  doAssert(plaintext == ptext)

test "encode/decode task":
  let t1 = newTask(1,"test1")
  echo "t1: ", t1
  let et1 = encodeTask(t1,b_publicKey,a_secretKey)
  echo "et1: ", et1
  let (dt1,pk) = decodeTask(et1,b_secretKey)
  doAssert(dt1.taskId == t1.taskId)

test "encode/decode resp":
  let t1 = newTask(1,"test1")
  echo "t1: ", t1
  let r1 = Resp(taskId: t1.taskId, resp: "COMPLETE")
  echo "r1: ", r1
  let er1 = encodeResp(r1,b_publicKey,a_secretKey)
  echo "er1: ", er1
  let (dr1,pk) = decodeResp(er1,b_secretKey)
  doAssert(dr1.taskId == r1.taskId)


# test "testing enc on a blank message":
#   let encMsg = encMsg(a_secretKey,b_publicKey,'')

# test "testing dec with wrong keys":
#   let encMsg = encMsg(a_secretKey,b_publicKey,'test')
#   let decMsg = decMsg('',encMsg)
  