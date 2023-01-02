import types
import flatty
import std/base64
import types

when defined(js):
  import jsffi
  var module {.importc.}: JsObject

import std/strutils

let URL_MAX_LEN* = 256

proc serEncConfig*(encMsg:EncConfig): string = 
  result = toFlatty(encMsg)

proc desEncConfig*(serEncMsg:string): EncConfig = 
  result = serEncMsg.fromFlatty(EncConfig)

proc serConfig*(encMsg:StaticConfig): string = 
  result = toFlatty(encMsg)

proc desConfig*(serEncMsg:string): StaticConfig = 
  result = serEncMsg.fromFlatty(StaticConfig)


proc padUrl*(url:string): string =
  let urlLen = url.len
  if urlLen < URL_MAX_LEN:
    result = url & "\0".repeat(URL_MAX_LEN-urlLen)
  else:
    raise (newException(ValueError, "URL is too long"))
  return result

proc createConfig(): StaticConfig =
  var config = StaticConfig()
  config.buildid = "\0".repeat(URL_MAX_LEN)
  config.deploymentid = "\0".repeat(URL_MAX_LEN)
  config.killEpoch = 0
  config.interval = 0
  config.callback = "\0".repeat(URL_MAX_LEN)
  return config

proc createEmptyConfig(): StaticConfig =
  var config = StaticConfig()
  config.buildid = "\0".repeat(URL_MAX_LEN)
  config.deploymentid = "\0".repeat(URL_MAX_LEN)
  config.killEpoch = 0
  config.interval = 0
  config.callback = "\0".repeat(URL_MAX_LEN)
  return config

proc b64Str*(msg:string): string = 
  result = encode(msg,safe=true)
 
proc unb64str*(msg:string): string = 
  result = decode(msg)

when defined(js):
  module.exports.padUrl = padUrl
  module.exports.desConfig = desConfig
  module.exports.serConfig = serConfig
  module.exports.serEncConfig = serEncConfig
  module.exports.desEncConfig = desEncConfig
  module.exports.createEmptyConfig = createEmptyConfig
  module.exports.b64Str = b64Str
  module.exports.unb64Str = unb64Str
