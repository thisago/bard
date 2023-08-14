import std/asyncdispatch
from std/os import getEnv

import pkg/dotenv

import pkg/bard

dotenv.load()

let ai = waitFor newBardAi getEnv "bard_cookies"

echo waitFor(ai.prompt "Tell me an Asian traditional history in ten words").text
