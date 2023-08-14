import std/asyncdispatch
from std/os import getEnv

import pkg/dotenv

import pkg/bard

dotenv.load()

let ai = waitFor newBardAi({
  "__Secure-1PSID": getEnv("bard_psid"),
  "__Secure-1PSIDTS": getEnv("bard_psidts")
})

var chat = ai.newBardAiChat

discard waitFor chat.prompt "my name is Luke"
echo waitFor(chat.prompt "what's my name?").text
