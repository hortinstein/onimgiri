# Package

version       = "0.1.0"
author        = "Hortinstein"
description   = "Onimgiri is a simple beacon that talks to a web server"
license       = "MIT"

srcDir        = "src"
binDir        = "bin"

installExt    = @["nim"]
bin           = @["agent,listener"]


# Dependencies
requires "nim >= 1.6.6"
requires "puppy"
requires "flatty"
requires "monocypher"
requires "printdebug"