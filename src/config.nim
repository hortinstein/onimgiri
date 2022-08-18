const LOOKUP_TABLE =
    when defined(release):
        staticRead("release.json")
    else:
        staticRead("debug.json")
type
  Agent = ref object
    buildid: string     #todo 
    deploymentid: string #todo 
    uuid: string #todo 
  
    connected: bool

type 
  EncyptedBytes = ref object

echo LOOKUP_TABLE