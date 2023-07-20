import std/asyncdispatch
from std/os import getEnv

import pkg/dotenv

import pkg/bard

dotenv.load()

let ai = waitFor newBardAi(
  psid = getEnv("bard_psid"),
  psidts = getEnv("bard_psidts")
)

echo waitFor(ai.prompt "show me cats images").text
