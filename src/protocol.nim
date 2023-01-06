import monocypher
import sysrandom
import flatty
import std/base64
import configjs
import types
import tasks
#[
  helper function to convert bytes to string
]# 
proc toString*(bytes: seq[byte]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

#[
  encrypts a message and returns a structure ready to be serialized and sent
]#
proc encMsg*( privateKey: Key, publicKey: Key, plaintext: seq[byte]): EncMsg =
  #derive the shared key and material needed to encrypt
  let sharedKey = crypto_key_exchange(privateKey, publicKey)
  let nonce = getRandomBytes(sizeof(Nonce))
  #perform encryption
  let (mac, ciphertext) = crypto_lock(sharedKey, nonce, plaintext)
  #create the return object
  let myPubKey = crypto_key_exchange_public_key(privateKey)
  result = EncMsg(publicKey: myPubKey,
                  nonce:nonce,
                  mac:mac,
                  cipherLen:cipherText.len,
                  cipherText:cipherText)
#[
  decrypts a message and returns a byte array
]#
proc decMsg*( privateKey: Key, encMsg: EncMsg): seq[byte] =
  #derive the shared key 
  let sharedKey = crypto_key_exchange(privateKey, encMsg.publicKey)
  #perform decryption
  result = crypto_unlock( sharedKey, 
                          encMsg.nonce, 
                          encMsg.mac, 
                          encMsg.ciphertext)

proc serEncMsg*(encMsg:object): string = 
  result = toFlatty(encMsg)

proc desEncMsg*(serEncMsg:string): EncMsg = 
  result = serEncMsg.fromFlatty(EncMsg)

proc encodeTask*(task: Task, privKey: Key, pubKey: Key): string =
  #convert string to byte array
  let serTask = cast[seq[byte]](toFlatty(task))
  let encSerTask = encMsg(privKey, pubKey, serTask)
  let serEncSerTask = serEncMsg(encSerTask)
  let b64SerEncSerTask = b64Str(serEncSerTask)
  return b64SerEncSerTask

proc encodeResp*(resp: Resp, privKey: Key, pubKey: Key): string =
  #convert string to byte array
  let serResp = cast[seq[byte]](toFlatty(resp))
  let encSerResp = encMsg(privKey, pubKey, serResp)
  let serEncSerResp = serEncMsg(encSerResp)
  let b64SerEncSerResp = b64Str(serEncSerResp)
  return b64SerEncSerResp

proc decodeTask*(b64SerEncSerTask: string,privKey:Key): (Task,Key) =
  let serEncSerTask =  unb64Str(b64SerEncSerTask)
  let encSerTask = desEncMsg(serEncSerTask)
  let serTask = decMsg(privKey, encSerTask)
  #flatty deserialization takes strings
  let task = toString(serTask).fromFlatty(Task) 
  return (task,encSerTask.publicKey)

proc decodeResp*(b64SerEncSerResp: string,privKey:Key): (Resp,Key) =
  let serEncSerResp =  unb64Str(b64SerEncSerResp)
  let encSerResp = desEncMsg(serEncSerResp)
  let serResp = decMsg(privKey, encSerResp)
  #flatty deserialization takes strings
  let resp = toString(serResp).fromFlatty(Resp) 
  return (resp,encSerResp.publicKey)

