import protocol
import flatty 
import monocypher
import sysrandom
import std/oids
import times

#this is used to store the encrypted bytes
type
  EncConfig* = ref object
    privKey: Key
    pubKey: Key
    encObj: EncMsg

type
  StaticConfig* = ref object
    buildid: Oid      #generated on build
    deploymentid: Oid #generated on deployment
    killEpoch*: int32  #what point should the agent stop calling back and delete
    interval*: int32   #how often should the agent call back
    callback*: string  #where the C2 is 


proc serEncConfig*(encMsg:StaticConfig): string = 
  result = toFlatty(encMsg)

proc desEncConfig*(serEncMsg:string): StaticConfig = 
  result = serEncMsg.fromFlatty(StaticConfig)

proc writeStringToFile(fileName: string, contents: string) =
  let f = open(filename, fmWrite)
  f.write(contents)
  defer: f.close()

proc readStringFromFile(fileName: string): string =
  let f = open(filename, fmRead)
  defer: f.close()
  result = f.readAll()

proc createEncConfig(): EncConfig =

  let config = new StaticConfig  
  config.buildid = genOid()
  config.deploymentid = genOid() #TODO make this part of config
  config.killEpoch = int32(epochTime() + (60 * 60 * 24 * 7)) #TODO make this configureable
  config.interval = 1000 #TODO 1 second
  config.callback = "http://localhost:8080/callback" #TODO make this configureable
  
  let configBytes = cast[seq[byte]](serEncConfig(config))
  
  let encConfig = new EncConfig
  encConfig.privKey = getRandomBytes(sizeof(Key))
  encConfig.pubKey = crypto_key_exchange_public_key(encConfig.privKey)
  encConfig.encObj = encMsg(encConfig.privKey, encConfig.pubKey,configBytes)
  result = encConfig

proc readEncConfig*(encConfig:EncConfig): StaticConfig =
  let configBytes = decMsg(encConfig.privKey, encConfig.encObj)
  let config = desEncConfig(toString(configBytes))
  result = config

# let testConfig = createEncConfig()
# let b64Str = b64str(toFlatty(testConfig))
# writeStringToFile("debug.config", b64Str)
# writeStringToFile("release.config", b64Str)
# let ub64Str = unb64str(b64Str)
# let test = ub64Str.fromFlatty(EncConfig)
# let testRead = readEncConfig(test)
# echo testRead.callback
