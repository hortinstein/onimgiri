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

### Trying for an endpoint
```
export const handler = async (event, context) => {
  if (event.httpMethod === 'POST') {
    console.log(JSON.parse(event.body))
    var username = JSON.parse(event.body).username
    var password = JSON.parse(event.body).password
    db.post.create({
      data: { title: username, body: password },
    })

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