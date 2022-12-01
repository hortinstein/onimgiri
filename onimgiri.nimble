# Package

version       = "0.1.0"
author        = "Hortinstein"
description   = "Onimgiri is a simple beacon that talks to a web server"
license       = "MIT"

srcDir        = "src"
binDir        = "bin"

installExt    = @["nim"]
bin           = @["agent,listener,config"]

# Dependencies
requires "nim >= 1.6.6"
requires "puppy"
requires "flatty"
requires "monocypher"
requires "printdebug"


task install, "Install the package":
  exec "nimble install"

task buildall, "Build the package":
  exec "nimble build config"
  exec "./bin/config"
  exec "nimble build"
  exec "nim js -d:nodejs --out:js/configjs.js -r src/configjs.nim"
  