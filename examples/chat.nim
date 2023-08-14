import std/asyncdispatch
from std/os import getEnv

import pkg/dotenv

import pkg/bard

dotenv.load()

let ai = waitFor newBardAi getEnv "bard_cookies"

var chat = ai.newBardAiChat

discard waitFor chat.prompt "my name is Luke"
echo waitFor(chat.prompt "what's my name?").text
