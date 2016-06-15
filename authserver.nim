import asynchttpserver, asyncdispatch, tables, sam

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

  Response = ref object of RootObj
    error: string
    errorMessage: string
    cause: string

  AuthenticationResponse = ref object of Response
    accessToken: string
    clientToken: string
    selectedProfile: GameProfile
    availableProfiles: seq[GameProfile]
    user: User

  HasJoinedMinecraftServerResponse = ref object of Response
    id: string
    properties: TableRef[string, Property]


  MinecraftProfilePropertiesResponse = ref object of Response
    id: string
    name: string
    properties: TableRef[string, Property]

  ProfileSearchResultRepsonse = ref object of Response
    profiles: seq[GameProfile]

  RefreshResponse = ref object of Response
    accessToken: string
    clientToken: string
    selectedProfile: GameProfile
    availableProfiles: seq[GameProfile]
    user: User


var server = newAsyncHttpServer()
proc cb(req: Request) {.async.} =
  if req.reqMethod != "post":
     await req.respond(Http501, "Internal server errror")
     return

  if req.url.path == "/authenticate":
    var
      request: AuthenticationRequest
      response: AuthenticationResponse
    request.loads(req.body)
    await req.respond(Http200,  "I got some JSON: " & $$request)


  await req.respond(Http200, "Hello World")

waitFor server.serve(Port(8080), cb)
