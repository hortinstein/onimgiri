
type
  Hash = array[64, byte]
  Key = array[32, byte]
  Nonce = array[24, byte]
  Mac = array[16, byte]
  Signature = array[64, byte]

type
  EncMsg* = object
    publicKey*: Key
    nonce*:     Nonce
    mac*:       Mac
    cipherLen*:  int
    cipherText*: seq[byte]

#this is used to store the encrypted bytes
type
  EncConfig* = ref object
    privKey*: Key
    pubKey*: Key
    encObj*: EncMsg

type
  StaticConfig* = ref object
    buildid*: string      #generated on build
    deploymentid*: string #generated on deployment
    killEpoch*: int32  #what point should the agent stop calling back and delete
    interval*: int32   #how often should the agent call back
    callback*: string  #where the C2 is 