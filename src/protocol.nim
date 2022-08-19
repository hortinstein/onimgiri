import monocypher
import sysrandom
import flatty
import std/base64

type
  EncryptedMessage* = object
    publicKey*: Key
    nonce*:     Nonce
    mac*:       Mac
    cipherLen:  int
    cipherText: seq[byte]

#[
  helper function to convert bytes to string
]# 
proc toString*(bytes: seq[byte]): string =
  result = newString(bytes.len)
  copyMem(result[0].addr, bytes[0].unsafeAddr, bytes.len)

#[
  encrypts a message and returns a structure ready to be serialized and sent
]#
proc encryptMessage*( privateKey: Key, 
                      publicKey: Key, 
                      plaintext: seq[byte]): EncryptedMessage =
  #derive the shared key and material needed to encrypt
  let sharedKey = crypto_key_exchange(privateKey, publicKey)
  let nonce = getRandomBytes(sizeof(Nonce))
  #perform encryption
  let (mac, ciphertext) = crypto_lock(sharedKey, nonce, plaintext)
  #create the return object
  let myPubKey = crypto_key_exchange_public_key(privateKey)
  result = EncryptedMessage(publicKey: myPubKey,
                              nonce:nonce,
                              mac:mac,
                              cipherLen:cipherText.len,
                              cipherText:cipherText)
#[
  decrypts a message and returns a byte array
]#
proc decryptMessage*( privateKey: Key, 
                      encMsg: EncryptedMessage): seq[byte] =
  #derive the shared key 
  let sharedKey = crypto_key_exchange(privateKey, encMsg.publicKey)
  #perform decryption
  result = crypto_unlock( sharedKey, 
                          encMsg.nonce, 
                          encMsg.mac, 
                          encMsg.ciphertext)

proc serializeEncryptMessage*(encMsg:EncryptedMessage): string = 
  result = toFlatty(encMsg)

proc deserializeEncryptMessage*(serEncMsg:string): EncryptedMessage = 
  result = serEncMsg.fromFlatty(EncryptedMessage)

proc base64Str*(msg:string): string = 
  result = encode(msg,safe=true)
  
proc unbase64str*(msg:string): string = 
  echo msg
  result = decode(msg)
  echo result