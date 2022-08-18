import asyncdispatch, asynchttpserver, uri, urlly, zippy

let server = newAsyncHttpServer()

proc cb(req: Request) {.async.} =
  echo "got request ", $req
  case req.reqMethod
  of HttpGet:
    if req.url.path == "/":
      await req.respond(Http200, "ok")
      return
  of HttpPost:
    if req.url.path == "/":
      echo req.headers
      if req.headers["Content-Length"] == "":
        await req.respond(Http200, "missing content-length header")
      else:
        await req.respond(Http200, req.body)
      
        echo req.body
      return
  else:
    discard
  await req.respond(Http404, "Not found.")

waitFor server.serve(Port(8080), cb)