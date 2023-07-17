from std/httpclient import newAsyncHttpClient, newHttpHeaders, post, close

const
  baseUrl = "https://bard.google.com"

type
  BardAi* = ref object
    sessionId: string
  Chat* = ref object
    ids: seq[string]

proc newBardAi*(sessionId: string): BardAi =
  ## Creates new Bard AI object
  new result
  result.sessionId = sessionId

proc prompt(self: BardAi; text: string): string =
  ## Make a text prompt to Google Bard
  discard
