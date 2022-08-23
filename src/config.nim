import protocol
import flatty 
import monocypher
const LOOKUP_TABLE =
    when defined(release):
        staticRead("release.json")
    else:
        staticRead("debug.json")

#this is used to store the encrypted bytes
type
  EncConfig = ref object
    privKey: Key
    encObj: seq[byte]

type
  StaticConfig = ref object
    buildid: string     #todo 
    deploymentid: string #todo 
    callback: string


proc serEncConfig*(encMsg:StaticConfig): string = 
  result = toFlatty(encMsg)

proc desEncConfig*(serEncMsg:string): StaticConfig = 
  result = serEncMsg.fromFlatty(StaticConfig)

proc writeStringToFile(fileName: string, contents: string) =
  let f = open(filename, fmWrite)
  f.write(contents)
  defer: f.close()

proc readStringFromFile(fileName: string): string =
  let f = open(filename, fmRead)
  defer: f.close()
  result = f.readAll()