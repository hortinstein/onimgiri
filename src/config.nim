import protocol
import flatty 
import monocypher
import sysrandom
import std/oids
import times
import std/strutils
import std/json
import os
import configjs
import types

let URL_MAX_LEN = 256
let BUILD_ID_LEN = 12

proc writeStringToFile*(fileName: string, contents: string) =
  let f = open(filename, fmWrite)
  f.write(contents)
  defer: f.close()

proc readStringFromFile*(fileName: string): string =
  let f = open(filename, fmRead)
  defer: f.close()
  result = f.readAll()

proc createConfig(): StaticConfig = 
  var config = StaticConfig()
  config.buildid = $(genOid())
  config.deploymentid = $(genOid())

proc createEmptyConfig(): StaticConfig =
  var config = StaticConfig()
  config.buildid = $(genOid())
  config.deploymentid = '\0'.repeat(BUILD_ID_LEN)
  echo config.buildid," size:",config.buildid.len
  config.killEpoch = 0
  config.interval = 0
  config.callback = '\0'.repeat(URL_MAX_LEN)
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

  # let configOut = "release.config"
  # let configIn = "release.json"
  let configOut = "debug.config"
  let configIn = "debug.json"


  genOutFile(configIn,configOut)