import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, newHttpHeaders, postContent, close,
                            HttpHeaders, getContent
from std/strformat import fmt
from std/strutils import split
from std/json import `$`, `%*`, newJNull, parseJson, `{}`, len, getStr
from std/uri import initUri, `$`, encodeQuery

from pkg/util/forStr import between

const
  hostUrl = "bard.google.com"
  baseUrl = "https://" & hostUrl

type
  BardAi* = ref object
    headers: HttpHeaders
    snlm0e: string
    reqId: int
  AiChat* = ref object
    ai: BardAi
    conversationId: string
    responseId: string
    choiceId: string

using
  self: BardAi

proc getSNlM0e(self) {.async.} =
  ## Gets the `SNlM0e` value from Google Bard webpage
  let client = newAsyncHttpClient(headers = self.headers)
  self.snlm0e = (await client.getContent baseUrl).between("SNlM0e\":\"", "\"")
  if self.snlm0e.len == 0:
    raise newException(Exception, "Cannot GET Google Bard `SNlM0e`")

func nextReqId(self): int =
  const sum = 100000
  if self.reqId == 0:
    sum
  else:
    self.reqId + sum

proc newBardAi*(psid, psidts: string): Future[BardAi] {.async.} =
  ## Creates new Bard AI object
  new result
  result.headers = newHttpHeaders({
    "Host": hostUrl,
    "X-Same-Domain": "1",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
    "Origin": baseUrl,
    "Referer": baseUrl & "/",
    "Cookie": fmt"__Secure-1PSID={psid}; __Secure-1PSIDTS={psidts}",
  })
  result.reqId = nextReqId result
  await result.getSNlM0e
  
proc newChat*(psid, psidts: string): Future[AiChat] {.async.} =
  ## Creates new Bard AI object
  new result
  result.ai = await newBardAi(psid, psidts)

# internal getters
template headers(chat: AiChat): BardAi.headers = chat.ai.headers
template reqId(chat: AiChat): BardAi.reqId = chat.ai.reqId
template snlm0e(chat: AiChat): BardAi.snlm0e = chat.ai.snlm0e

proc prompt(self: BardAi or AiChat; text: string): Future[string] {.async.} =
  ## Make a text prompt to Google Bard
  var client = newAsyncHttpClient(headers = self.headers)

  var url = initUri()
  url.path = "/_/BardChatUi/data/assistant.lamda.BardFrontendService/StreamGenerate"
  url.hostname = hostUrl
  url.scheme = "https"
  url.query = encodeQuery({
    "bl": "boq_assistant-bard-web-server_20230711.08_p0",
    "_reqID": $self.reqId,
    "rt": "c",
  })

  when self is BardAi:
    let ids = newJNull()
  else:
    let ids = %*[
      self.conversationID,
      self.responseID,
      self.choiceID
    ]
  let
    resp = await client.postContent(url, {
      "f.req": $ %*[
        newJNull(),
        $ %*[
          %*[text],
          newJNull(),
          ids
        ]
      ],
      "at": self.snlm0e
    }.encodeQuery)
    json = resp.split("\n")[3].parseJson{0}{2}

  if json.isNil:
    raise newException(Exception, fmt"Google Bard sent an unrecognizable response: `{resp}`")
  let bardResponse = json.getStr.parseJson{4, 0}

  result = bardResponse{1, 0}.getStr

when isMainModule:
  let ai = waitFor newBardAi(
    psid = "",
    psidts = "" 
  )
  echo waitFor ai.prompt "Tell me an Asian traditional history in ten words"
