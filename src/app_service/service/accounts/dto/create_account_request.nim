import json, std/options
import ./wallet_secretes_config
import ./image_crop_rectangle

export wallet_secretes_config
export image_crop_rectangle

type
  CreateAccountRequest* = object
    backupDisabledDataDir*: string
    kdfIterations*: int
    deviceName*: string
    displayName*: string
    password*: string
    imagePath*: string
    imageCropRectangle*: ImageCropRectangle
    customizationColor*: string
    emoji*: string

    wakuV2Nameserver*: Option[string]
    wakuV2LightClient*: bool

    logLevel*: Option[string]
    logFilePath*: string
    logEnabled*: bool

    previewPrivacy*: bool

    verifyTransactionURL*: Option[string]
    verifyENSURL*: Option[string]
    verifyENSContractAddress*: Option[string]
    verifyTransactionChainID*: Option[int64]
    upstreamConfig*: string
    networkID*: Option[uint64]

    walletSecretsConfig*: WalletSecretsConfig

    torrentConfigEnabled*: Option[bool]
    torrentConfigPort*: Option[int]

proc toJson*(self: CreateAccountRequest): JsonNode =
  result = %*{
    "backupDisabledDataDir": self.backupDisabledDataDir,
    "kdfIterations": self.kdfIterations,
    "deviceName": self.deviceName,
    "displayName": self.displayName,
    "password": self.password,
    "imagePath": self.imagePath,
    "imageCropRectangle": self.imageCropRectangle,
    "customizationColor": self.customizationColor,
    "emoji": self.emoji,
    "wakuV2LightClient": self.wakuV2LightClient,
    "logFilePath": self.logFilePath,
    "logEnabled": self.logEnabled,
    "previewPrivacy": self.previewPrivacy,
    "upstreamConfig": self.upstreamConfig,
  }

  if self.logLevel.isSome():
    result["logLevel"] = %self.logLevel.get("")

  if self.wakuV2Nameserver.isSome():
    result["wakuV2Nameserver"] = %self.wakuV2Nameserver.get()

  if self.verifyTransactionURL.isSome():
    result["verifyTransactionURL"] = %self.verifyTransactionURL.get()

  if self.verifyENSURL.isSome():
    result["verifyENSURL"] = %self.verifyENSURL.get()
    
  if self.verifyENSContractAddress.isSome():
    result["verifyENSContractAddress"] = %self.verifyENSContractAddress.get()

  if self.verifyTransactionChainID.isSome():
    result["verifyTransactionChainID"] = %self.verifyTransactionChainID.get()

  if self.networkID.isSome():
    result["networkID"] = %self.networkID.get()

  if self.torrentConfigEnabled.isSome():
    result["torrentConfigEnabled"] = %self.torrentConfigEnabled.get()

  if self.torrentConfigPort.isSome():
    result["torrentConfigPort"] = %self.torrentConfigPort.get()

  for key, value in self.walletSecretsConfig.toJson().pairs():
    result[key] = value

