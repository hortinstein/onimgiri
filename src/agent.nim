import asyncdispatch, asyncnet
import sysrandom
import std/base64

#third party libraries
import puppy #http comms library
import monocypher
import flatty

type
  Agent* = ref object
    callbackAddr: string     #todo 
    sleep: int16 #todo 
    
proc getTasks(agent: Agent): string = 
  result = fetch(agent.callbackAddr)
  
#retrieved the 
proc postResult(agent: Agent, taskResult: string): string = 
  let req = Request(
    url: parseUrl(agent.callbackAddr),
    verb: "post",
    body: "test the post"
  )
  result = fetch(req).body


let agent= Agent(callbackAddr:"http://localhost:8080/",sleep: 100)

echo getTasks(agent)
echo postResult(agent,"my result")