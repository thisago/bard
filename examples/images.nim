import std/asyncdispatch
from std/os import getEnv

import pkg/dotenv

import pkg/bard

dotenv.load()

let ai = waitFor newBardAi getEnv "bard_cookies"

for img in waitFor(ai.prompt "show me cats images").images:
  echo img[]
