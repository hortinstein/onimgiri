#const LOOKUP_TABLE: array[8, byte] = ["A","A","A","A","A","A","A","A"
 
#debug
when not defined(release):
  const LOOKUP_TABLE: string = "{this:is:test:json}"
#release
when defined(release):
  const LOOKUP_TABLE: string = "{this:is:release:json}"

type
  Agent = ref object
    buildid: string     #todo 
    deploymentid: string #todo 
    uuid: string #todo 
  
    connected: bool

type 
  EncyptedBytes = ref object
