import asyncdispatch
import sysrandom
import std/osproc
import unittest
import tables

import configjs 
import config
import tasks
import monocypher
import types 
import asynchttpserver, uri, flatty

proc serveTasks(tt: TaskTable, server: AsyncHttpServer) =
  # Define a nested proc that will handle incoming requests
  proc cb(req: Request, tt: TaskTable,server: AsyncHttpServer) {.async.} =
    echo req.url
    # Use a case statement to handle different request methods
    case req.reqMethod
    # If the request method is an HTTP GET
    of HttpGet:
      echo "got a get request"
      # If the request URL path is "/"
      if req.url.path == "/":
        # Get the task ID for an unsent task
        let taskId = getUnsentTask(tt)
        # If a task was returned
        if taskId != "":
          # Send the task data in the response
          await req.respond(Http200,toFlatty(tt.tasks[taskId]))
          # Mark the task as retrieved
          assert (tt.tasks[taskId].retrieved == true) 
        # If no tasks are available
        else:
          # Send an empty response
          waitFor req.respond(Http200, "")
        return
    # If the request method is an HTTP POST
    of HttpPost:
      echo "got a post request"
      # If the request URL path is "/"
      
      if req.url.path == "/":
        # Get the response data from the request body
        let resp = req.body.fromFlatty(Resp)
        # Add the response to the task table
        addTaskResp(tt, resp)
        # Send an empty response
        waitFor req.respond(Http200, "")
        return
    # If the request method is neither an HTTP GET nor an HTTP POST
    else:
      # Discard the request
      discard
    # Send an HTTP 404 response with the message "Not found."
    await req.respond(Http404, "Not found.")

  # If the server is ready to accept requests
  if server.shouldAcceptRequest():
    # Wait for the server to accept a request and pass it to the cb proc
    echo "waiting for the get request"
    waitFor server.acceptRequest(
      proc (req: Request): Future[void] = cb(req, tt,server)
    )
    echo "waiting for the post request"
    # Wait for the server to accept another request and pass it to the cb proc
    waitFor server.acceptRequest(
      proc (req: Request): Future[void] = cb(req, tt,server)
    )
    waitFor sleepAsync(1000)
    

suite "test the retrieval of tasks and response adding":
  var tt = newTaskTable()
  let t1 = newTask(1,"test1")
  let t2 = newTask(2,"test2")
  
  test "getting an unsent task":
    addTask(tt,t1)
    let id = getUnsentTask(tt)
    assert (id == t1.taskId)
    assert (true == tt.tasks[t1.taskId].retrieved)
  test "testing what happens when there are no unsent tasks":
    let id = getUnsentTask(tt)
    assert (id == "")    
  test "testing adding a response":
    let r1 = Resp(taskId: t1.taskId, resp: "resp1")
    addTaskResp(tt, r1)
    assert (tt.tasks[t1.taskId].resp == "resp1")
    let f = waitFor getTaskResp(tt,r1.taskId)
    assert ( f == "resp1")
  test "testing adding another item to the tt":
    addTask(tt,t2)
    let id = getUnsentTask(tt)
    assert (id == t2.taskId)
 
suite "tests the agent for task response":
  let c2secretKey = getRandomBytes(sizeof(Key))
  let c2PublicKey = crypto_key_exchange_public_key(c2secretKey)
  
  #gathers the agent context from the config file
  let context = staticRead("../debug.config")
  let ub64Str = unb64str(context)
  let encConfig = ub64Str.fromFlatty(EncConfig)
  let agentPubKey = encConfig.privKey

  var tt = newTaskTable()
  let t1 = newTask(1,"test1")
  let t2 = newTask(2,"test2")
  let t3 = newTask(3,"test3")
  let server = newAsyncHttpServer()
  server.listen(Port(8080))
  
  # setup:
      # For the startProcess variant
  let agent = startProcess("./bin/agent", options = {poUsePath})
  # discard agent.waitForExit() # Force the program to block until done, not needed if have other computation
  # let agent = agent.outputstream.readAll

  test "test task1":
    addTask(tt,t1)
    serveTasks(tt,server)
    assert (tt.tasks[t1.taskId].resp == "COMPLETE")
    echo tt.tasks

  test "test task2":
    addTask(tt,t2)
    serveTasks(tt,server)
    assert (tt.tasks[t2.taskId].resp == "COMPLETE")
    echo tt.tasks

  test "test task3":
    addTask(tt,t3)
    serveTasks(tt,server)
    assert (tt.tasks[t3.taskId].resp == "COMPLETE")
    echo tt.tasks

  # teardown:
  agent.close() # Free Resources