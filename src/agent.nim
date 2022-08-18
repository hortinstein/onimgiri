import asyncdispatch, asyncnet
import sysrandom
import std/base64
import std/os
#third party libraries
import puppy #http comms library
import monocypher
import flatty

type
  Agent* = ref object
    callbackAddr: string     #todo 
    sleep: int16 #todo 

#retrieves all of the tasks for the agent  
proc getTasks(agent: Agent): string = 
  result = fetch(agent.callbackAddr)
  
#posts the task results for the agent
proc postResult(agent: Agent, taskResult: string): string = 
  let req = Request(
    url: parseUrl(agent.callbackAddr),
    verb: "post",
    body: "test the post"
  )
  result = fetch(req).body


let agent= Agent(callbackAddr:"http://localhost:8080/",sleep: 1000)

#the tasking loop
while true:
  echo getTasks(agent)
  echo postResult(agent,"my result")
  sleep(agent.sleep)