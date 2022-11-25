# onimgiri

- [onimgiri](#onimgiri)
    - [Theme Music](#theme-music)
    - [Helpful Libraries](#helpful-libraries)
    - [Compiling](#compiling)

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
