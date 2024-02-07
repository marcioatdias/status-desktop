import io_interface
import app/core/eventemitter
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/devices/service as devices_service
import app_service/service/node/service as node_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service
    nodeService: node_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  nodeService: node_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.nodeService = nodeService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_LOCAL_PAIRING_STATUS_UPDATE) do(e:Args):
    let data = LocalPairingStatus(e)
    self.delegate.onLocalPairingStatusUpdate(data)

proc hasPairedDevices*(self: Controller): bool =
  return self.walletAccountService.hasPairedDevices()

proc getRpcStats*(self: Controller): string =
  return self.nodeService.getRpcStats()

proc resetRpcStats*(self: Controller) =
  self.nodeService.resetRpcStats()
