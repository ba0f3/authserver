import asynchttpserver, asyncdispatch, tables, marshal, nuuid, rethinkdb

type
  Agent = object
    name: string
    version: int

  Property = object
    name: string
    value: string
    signature: string

  GameProfile = object
    id: string
    name: string
    properties: TableRef[string, Property]
    legacy: bool

  Platform = object
    os: string
    version: int
    word: int

  User = object
    id: string
    properties: TableRef[string, Property]

  AuthenticationRequest = object
    agent: Agent
    username: string
    password: string
    clientToken: string

  InvalidateRquest = object
    accessToken: string
    clientToken: string

  JoinMinecraftServerRequest = object
    accessToken: string
    selectedProfile: string
    serverId: string

  RefreshRequest = object
    clientToken: string
    accessToken: string
    selectedProfile: GameProfile

  ValidateRequest = object
    clientToken: string
    accessToken: string

  ErrorResponse = object
    error: string
    errorMessage: string
    cause: string

  AuthenticationResponse = object
    accessToken: string
    clientToken: string
    selectedProfile: GameProfile
    availableProfiles: seq[GameProfile]
    user: User

  HasJoinedMinecraftServerResponse = object
    id: string
    properties: TableRef[string, Property]


  MinecraftProfilePropertiesResponse = object
    id: string
    name: string
    properties: TableRef[string, Property]

  ProfileSearchResultRepsonse = object
    profiles: seq[GameProfile]

  RefreshResponse = object
    accessToken: string
    clientToken: string
    selectedProfile: GameProfile
    availableProfiles: seq[GameProfile]
    user: User


proc newErrorResponse(error, errorMessage: string, cause: string = nil): string =
    if cause.isNil:
      "{\"error\": \"" & error & "\", \"errorMessage\": \"" & errorMessage & "\"}"
    else:
      "{\"error\": \"" & error & "\", \"errorMessage\": \"" & errorMessage & "\", \"cause\": \"" & cause & "\"}"


proc cb(req: Request) {.async.} =
  if req.reqMethod != "post":
     await req.respond(Http501, "Internal server errror")
     return

  echo "<<< ", req.body

  if req.url.path == "/authenticate":
    var
      request: AuthenticationRequest
      response: AuthenticationResponse
      error: string = nil

    try:
      request = to[AuthenticationRequest](req.body)
    except:
      error = newErrorResponse("Bad Request", "Unable to parse json data", getCurrentExceptionMsg())

    if not error.isNil:
      await req.respond(Http400, error)

    if request.clientToken.isNil or request.clientToken == "":
      response.clientToken = generateUUID()
    else:
      response.clientToken = request.clientToken

    response.accessToken = "aa"

    await req.respond(Http200, $$response)





  await req.respond(Http200, "Hello World")

let server = newAsyncHttpServer()
waitFor server.serve(Port(8888), cb)
