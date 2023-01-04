import asyncdispatch, tables
import std/tables
import std/oids
import std/strutils

# Define a type for tasks
type 
  Task* = object
    taskId*: string # Unique identifier for the task
    taskNum*: int # Task number
    retrieved*: bool # Whether the task has been retrieved
    complete*: bool # Whether the task has been completed
    req*: string # Request data for the task
    resp*: string # Response data for the task

# Define a type for responses
type
  Resp* = object
    taskId*: string # Unique identifier for the task
    resp*: string # Response data for the task

# To use the async version of the function, you will need to
# wrap it in a call to runAsync

# Create a new task object
proc newTask*(taskNum: int, req: string): Task =
  # Generate a unique ID for the task
  let id = $(genOid())
  # Return a new Task object with the specified task number and request data
  Task(taskId:id , taskNum: taskNum, complete: false, req: req, resp: "")

# Define a type for the task table
type
  TaskTable* = ref object
    tasks*: Table[string, Task] # Table of tasks, indexed by task ID

# Get the ID of the first unsent task in the task table
proc getUnsentTask*(taskTable: TaskTable): string =
  # Iterate through the task IDs in the task table
  for taskId in taskTable.tasks.keys:
    # If the task has not been retrieved
    if not taskTable.tasks[taskId].retrieved:
      # Mark the task as retrieved
      taskTable.tasks[taskId].retrieved = true
      # Return the task ID
      return taskId
  # If no tasks are available, return an empty string
  return ""

# Create a new task table
proc newTaskTable*(): TaskTable =
  # Return a new task table with an empty tasks table
  return TaskTable(tasks: initTable[string, Task]())

# Add a task to the task table
proc addTask*(taskTable: TaskTable, task: Task) =
  # Get the task ID
  var id = task.taskId
  # Add the task to the task table
  taskTable.tasks[id] = task

# Add a response to a task in the task table
proc addTaskResp*(taskTable: TaskTable, resp: Resp) =
  try:
    # Set the response data for the task
    taskTable.tasks[resp.taskId].resp = resp.resp
    # Mark the task as complete
    taskTable.tasks[resp.taskId].complete = true
  except KeyError: #TODO better error handling
    # If the task ID is not found in the task table, print an error message
    echo "KeyError adding resp"

# Remove a task from the task table
proc rmTask*(taskTable: TaskTable, taskId: string) =
  # Remove the task from the task table
  taskTable.tasks.del(taskId)

# Get the response data for a task in the task table
proc getTaskResp*(taskTable: TaskTable, taskId: string): Future[string] {.async.} =
  # Save the task ID in a local variable
  var id = taskId
  try:
    # Keep checking the response data for the task until it is not empty
    while (taskTable.tasks[id].resp == ""):
      # Wait for one second before checking again
      await sleepAsync(1000)
  # If the task ID is not found in the task table
  except KeyError: #TODO better error handling
    # Print an error message
    echo " KeyError gettting resp"
    # Return an empty string
    return ""
  # Return the response data for the task
  return taskTable.tasks[id].resp