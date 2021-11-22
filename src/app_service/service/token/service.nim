import NimQml, json, sequtils, chronicles, strformat, strutils
import eventemitter
from sugar import `=>`
import web3/ethtypes
from web3/conversions import `$`
import status/statusgo_backend_new/custom_tokens as custom_tokens
import ../setting/service as setting_service
import ../settings/service as settings_service
import ../../../app/core/tasks/[qt, threadpool]
import ./dto, ./static_token

export dto

logScope:
  topics = "token-service"

include async_tasks

# Signals which may be emitted by this service:
const SIGNAL_TOKEN_DETAILS_LOADED* = "SIGNAL_TOKEN_DETAILS_LOADED"

type
  TokenDetailsLoadedArgs* = ref object of Args
    tokenDetails*: string

type 
  CustomTokenAdded* = ref object of Args
    token*: TokenDto

type 
  CustomTokenRemoved* = ref object of Args
    token*: TokenDto

type
  VisibilityToggled* = ref object of Args
    token*: TokenDto

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    settingService: setting_service.Service
    settingsService: settings_service.Service
    tokens: seq[TokenDto]

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    settingService: setting_service.Service,
    settingsService: settings_service.Service
    ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingService = settingService
    result.settingsService = settingsService
    result.tokens = @[]

  proc getDefaultVisibleSymbols(self: Service): seq[string] =
    let networkSlug = self.settingService.getSetting().currentNetwork.slug
    
    if networkSlug == "mainnet_rpc":
      return @["SNT"]

    if networkSlug == "testnet_rpc" or networkSlug == "rinkeby_rpc":
      return @["STT"]

    return @[]


  proc init*(self: Service) =
    try:
      var activeTokenSymbols = self.settingService.getSetting().activeTokenSymbols
      if activeTokenSymbols.len == 0:
        activeTokenSymbols = self.getDefaultVisibleSymbols()

      let static_tokens = static_token.all().map(
        proc(x: TokenDto): TokenDto =
          x.isVisible = activeTokenSymbols.contains(x.symbol)
          return x
      )

      let response = custom_tokens.getCustomTokens()
      self.tokens = concat(
        static_tokens,
        map(response.result.getElems(), proc(x: JsonNode): TokenDto = x.toTokenDto(activeTokenSymbols))
      ).filter(
        proc(x: TokenDto): bool = x.chainId == self.settingService.getSetting().currentNetwork.id
      )

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getTokens*(self: Service): seq[TokenDto] =
    return self.tokens

  proc addCustomToken*(self: Service, address: string, name: string, symbol: string, decimals: int) =
    custom_tokens.addCustomToken(address, name, symbol, decimals, "")
    let token = newDto(
      name,
      self.settingService.getSetting().currentNetwork.id,
      fromHex(Address, address),
      symbol,
      decimals,
      false,
      true
    )
    self.tokens.add(token)
    self.events.emit("token/customTokenAdded", CustomTokenAdded(token: token))

  proc toggleVisible*(self: Service, symbol: string) =
    var tokenChanged = self.tokens[0]
    for token in self.tokens:
      if token.symbol == symbol:
        token.isVisible = not token.isVisible
        tokenChanged = token
        break

    let visibleSymbols = self.tokens.filter(t => t.isVisible).map(t => t.symbol)
    discard self.settingService.saveSetting("wallet/visible-tokens", visibleSymbols)
    self.events.emit("token/visibilityToggled", VisibilityToggled(token: tokenChanged))

  proc removeCustomToken*(self: Service, address: string) =
    custom_tokens.removeCustomToken(address)
    var index = -1

    for idx, token in self.tokens.pairs():
      if $token.address == address:
        index = idx
        break

    let tokenRemoved = self.tokens[index]
    self.tokens.del(index)
    self.events.emit("token/customTokenRemoved", CustomTokenRemoved(token: tokenRemoved))

  proc tokenDetailsResolved*(self: Service, tokenDetails: string) {.slot.} =
    self.events.emit(SIGNAL_TOKEN_DETAILS_LOADED, TokenDetailsLoadedArgs(
      tokenDetails: tokenDetails
    ))
    
  proc getTokenDetails*(self: Service, address: string) =
    let chainId = self.settingsService.getCurrentNetworkDetails().config.networkId
    let arg = GetTokenDetailsTaskArg(
      tptr: cast[ByteAddress](getTokenDetailsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "tokenDetailsResolved",
      chainId: chainId,
      address: address
    )
    self.threadpool.start(arg)
