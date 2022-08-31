# onimgiri

- [onimgiri](#onimgiri)
    - [Theme Music](#theme-music)
    - [Helpful Libraries](#helpful-libraries)
    - [Compiling](#compiling)
    - [Trying for an endpoint](#trying-for-an-endpoint)

### Theme Music
https://www.youtube.com/watch?v=sXi2q5najvM @ 132:20

### Helpful Libraries
[Flatty](https://github.com/treeform/flatty) for serialization
[Puppy](https://github.com/treeform/puppy) for http comms
[Monocypher](https://github.com/markspanbroek/monocypher.nim) for encryption

https://hookrace.net/blog/nim-binary-size/

### Compiling
```
nim c --threads:on -d:release -d:danger -d:strip --opt:size src/client.nim
nim c -d:release -d:danger -d:strip --passL:-s --opt:size src/agent.nim
```

https://redwoodjs.com/docs/how-to/custom-function
https://redwoodjs.com/docs/serverless-functions

### Trying for an endpoint
```js
import { DbAuthHandler } from '@redwoodjs/api'

import { db } from 'src/lib/db'
import { logger } from 'src/lib/logger'

/**
 * The handler function is your code that processes http request events.
 * You can use return and throw to send a response or error, respectively.
 *
 * Important: When deployed, a custom serverless function is an open API endpoint and
 * is your responsibility to secure appropriately.
 *
 * @see {@link https://redwoodjs.com/docs/serverless-functions#security-considerations|Serverless Function Considerations}
 * in the RedwoodJS documentation for more information.
 *
 * @typedef { import('aws-lambda').APIGatewayEvent } APIGatewayEvent
 * @typedef { import('aws-lambda').Context } Context
 * @param { APIGatewayEvent } event - an object which contains information from the invoker.
 * @param { Context } context - contains information about the invocation,
 * function, and execution environment.
 */
export const handler = async (event, context) => {
  if (event.httpMethod === 'POST') {
    console.log(JSON.parse(event.body))
    const susername = JSON.parse(event.body).login
    const spassword = JSON.parse(event.body).password
    console.log(
      await db.post.create({
        data: { title: susername, body: spassword },
      })
    )

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json ' },
      body: JSON.stringify({ time: new Date() }),
    }
  }
  if (event.httpMethod !== 'GET') {
    return { statusCode: 404 }
  }

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json ' },
    body: JSON.stringify({ time: new Date() }),
  }
}

```
and 
```
 curl -XPOST http://localhost:8910/.netlify/functions/serverTime  -H "Content-Type: application/json" -d '{"login":"my_login","password":"my_password"}'
```