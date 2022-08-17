import json
type
  Message* = object
    username*: string
    message*: string

proc parseMessage*(data: string): Message =
  let dataJson = parseJson(data)
  result.username = dataJson["username"].getStr()
  result.message = dataJson["message"].getStr()

proc createMessage*(username, message: string): string =
  result = $(%{
    "username": %username,
    "message": %message
  }) & "\c\l"

block:
  let expected = """{"username":"dom","message":"hello"}""" & "\c\l"
  doAssert createMessage("dom", "hello") == expected



