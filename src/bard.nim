import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, newHttpHeaders, postContent, close,
                            HttpHeaders, getContent, HttpRequestError
from std/strformat import fmt
from std/strutils import split, replace, join
from std/json import `$`, `%*`, newJNull, parseJson, `{}`, len, getStr, JsonNode,
                      items, JNull, JsonParsingError
export json.items # Why it doesn't compiles without this?

from std/uri import `$`, encodeQuery, Uri
from std/sugar import collect

from pkg/util/forStr import between

const
  hostUrl = "bard.google.com"
  baseUrl = "https://" & hostUrl

type
  BardAi* = ref object
    headers: HttpHeaders
    snlm0e: string
    cfb2h: string ## `cl` param; The Bard model
    reqId: int
    server: string
  BardAiChat* = ref object
    ai*: BardAi
    conversationId: string
    responseId: string
    choiceId: string
  BardAiResponse* = ref object
    text*: string
    images*: seq[BardAiImage]
    drafts*: seq[BardAiResponseDraft]
    relatedSearches*: seq[string] ##z< "Google it" button
  BardAiResponseDraft* = tuple
    id, text: string
  BardAiImage* = ref object
    tag*: string
    url*: string
    source*: BardAiImageSource
  BardAiImageSource* = ref object
    original*: string
    website*: string
    name*: string
    favicon*: string

using
  self: BardAi
  chat: BardAiChat

type
  BardCantGetSnlm0e* = object of CatchableError
    ## Cannot get Google Bard `SNlM0e` param from HTML
  BardCantGetCfb2h* = object of CatchableError
    ## Cannot get Google Bard `cfb2h` param from HTML
  BardUnrecognizedResp* = object of CatchableError
    ## Google Bard sent an unrecognizable response, maybe they changed the data
    ## structure
  BardExpiredSession* = object of CatchableError
    ## Your Google account session was expired

proc getBardParams(self) {.async.} =
  ## Gets the `SNlM0e` and `cfb2h` from Google Bard webpage
  try:
    let
      client = newAsyncHttpClient(headers = self.headers)
      html = await client.getContent baseUrl
      params = html.between("window.WIZ_global_data", "};")

    self.snlm0e = params.between("SNlM0e\":\"", "\"")
    self.cfb2h = params.between("cfb2h\":\"", "\"")
  except HttpRequestError:
    discard
  if self.snlm0e.len == 0:
    raise newException(BardCantGetSnlm0e, "Cannot GET Google Bard `SNlM0e`")
  if self.cfb2h.len == 0:
    raise newException(BardCantGetCfb2h, "Cannot GET Google Bard `cfb2h`")

func nextReqId(self): int =
  const sum = 100000
  if self.reqId == 0:
    sum
  else:
    self.reqId + sum

proc newBardAi*(cookies: string): Future[BardAi] {.async.} =
  ## Creates new Bard AI object
  ##
  ## Required cookies: `__Secure-1PSID` and `__Secure-1PSIDTS`
  new result
  result.headers = newHttpHeaders({
    "Host": hostUrl,
    "X-Same-Domain": "1",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
    "Origin": baseUrl,
    "Referer": baseUrl & "/",
    "Cookie": cookies
  })
  result.reqId = nextReqId result
  await getBardParams result

proc newBardAi*(cookies: openArray[(string, string)]): Future[BardAi] =
  ## Alias that transforms cookies to string
  newBardAi collect(for cookie in cookies: cookie[0] & "=" & cookie[1]).join ";"

proc newBardAiChat*(self): BardAiChat =
  ## Creates new Bard AI Chat object
  new result
  result.ai = self

# internal getters
template headers(chat): BardAi.headers = chat.ai.headers
template reqId(chat): BardAi.reqId = chat.ai.reqId
template snlm0e(chat): BardAi.snlm0e = chat.ai.snlm0e
template cfb2h(chat): BardAi.cfb2h = chat.ai.cfb2h

func buildQuery(self: BardAi or var BardAiChat; prompt: string): string =
  ## Creates the Bard's batchexecute query body
  when self is BardAi:
    let ids = newJNull()
  else:
    let ids = %*[
      self.conversationID,
      self.responseID,
      self.choiceID
    ]
  result = encodeQuery {
    "f.req": $ %*[
      newJNull(),
      $ %*[
        %*[prompt],
        newJNull(),
        ids
      ]
    ],
    "at": self.snlm0e
  }

func buildUrl(self: BardAi or var BardAiChat): Uri =
  ## Creates the Bard's batchexecute URL
  result.path = "/_/BardChatUi/data/assistant.lamda.BardFrontendService/StreamGenerate"
  result.hostname = hostUrl
  result.scheme = "https"
  result.query = encodeQuery({
    "bl": self.cfb2h,
    "_reqID": $self.reqId,
  })

proc getRespJson(resp: string): JsonNode =
  try:
    let json = resp.split("\n")[2].parseJson{0}{2}
    if not json.isNil:
      return parseJson getStr json
  except JsonParsingError:
    discard
  raise newException(BardUnrecognizedResp,
    fmt"Google Bard sent an unrecognizable response: `{resp}`")

func extractImages(node: JsonNode): seq[BardAiImage] =
  ## Extracts all images of JSON Bard response
  if node.kind != JNull:
    for imgNode in node:
      var img = new BardAiImage
      img.tag = imgNode{2}.getStr
      img.url = imgNode{3, 0, 0}.getStr
      new img.source
      img.source.original = imgNode{0, 0, 0}.getStr
      img.source.website = imgNode{1, 0, 0}.getStr
      img.source.name = imgNode{1, 1}.getStr
      img.source.favicon = imgNode{1, 3}.getStr
      result.add img

func applyImages(text: string; images: seq[BardAiImage]): string =
  result = text
  for image in images:
    result = result.replace(image.tag, fmt"!{image.tag}({image.url})")

proc prompt*(
  self: BardAi or var BardAiChat;
  text: string
): Future[BardAiResponse] {.async.} =
  ## Make a text prompt to Google Bard
  var client = newAsyncHttpClient(headers = self.headers)
  var resp: JsonNode
  try:
    resp = getRespJson await client.postContent(
      self.buildUrl,
      self.buildQuery text
    )
  except HttpRequestError:
    raise newException(BardExpiredSession,
        "Your Google account session was expired: " & getCurrentExceptionMsg())
  let bardData = resp{4, 0}

  new result
  result.images = extractImages bardData{4}
  result.text = bardData{1, 0}.getStr.applyImages result.images

  for draft in resp{4}:
    result.drafts.add BardAiResponseDraft (
      id: draft{0}.getStr,
      text: collect(for txt in draft{1}: getStr txt).join "\l"
    )

  for suggestion in resp{2}:
    result.relatedSearches.add getStr suggestion{0}

  when self is BardAiChat:
    self.conversationId = resp{1}{0}.getStr
    self.responseId = resp{1}{1}.getStr
    self.choiceId = resp{4}{0}{0}.getStr

when isMainModule:
  let ai = waitFor newBardAi("")

  var chat = ai.newBardAiChat
  # echo waitFor ai.prompt "Tell me an Asian traditional history in ten words"
  echo waitFor(chat.prompt "tell me 2 jokes")[]
