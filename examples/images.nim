import std/asyncdispatch
from std/os import getEnv

import pkg/dotenv

import pkg/bard

dotenv.load()

let ai = waitFor newBardAi({
  "__Secure-1PSID": getEnv("bard_psid"),
  "__Secure-1PSIDTS": getEnv("bard_psidts")
})

for img in waitFor(ai.prompt "show me cats images").images:
  echo img[]
