import NimQml, json, stint, strutils

import ./io_interface
import ../../../shared_models/token_model as token_model
import ./grouped_account_assets_model as grouped_account_assets_model
import app_service/service/wallet_account/service

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      assets: token_model.Model
      groupedAccountAssetsModel: grouped_account_assets_model.Model
      assetsLoading: bool
      hasBalanceCache: bool
      hasMarketValuesCache: bool

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.assets.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.setup()
    result.delegate = delegate
    result.assets = token_model.newModel()
    result.groupedAccountAssetsModel = grouped_account_assets_model.newModel(delegate.getGroupedAccountAssetsDataSource())

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getAssetsModel*(self: View): token_model.Model =
    return self.assets

  proc assetsChanged(self: View) {.signal.}
  proc getAssets*(self: View): QVariant {.slot.} =
    return newQVariant(self.groupedAccountAssetsModel)
  QtProperty[QVariant] assets:
    read = getAssets
    notify = assetsChanged   

  proc groupedAccountAssetsModelChanged(self: View) {.signal.}
  proc getGroupedAccountAssetsModel*(self: View): QVariant {.slot.} =
    return newQVariant(self.groupedAccountAssetsModel)
  QtProperty[QVariant] groupedAccountAssetsModel:
    read = getGroupedAccountAssetsModel
    notify = groupedAccountAssetsModelChanged

  proc getAssetsLoading(self: View): QVariant {.slot.} =
    return newQVariant(self.assetsLoading)
  proc assetsLoadingChanged(self: View) {.signal.}
  QtProperty[QVariant] assetsLoading:
    read = getAssetsLoading
    notify = assetsLoadingChanged

  proc setAssetsLoading*(self:View, assetLoading: bool) =
    if assetLoading != self.assetsLoading:
      self.assetsLoading = assetLoading
      self.assetsLoadingChanged()

  proc getHasBalanceCache(self: View): QVariant {.slot.} =
    return newQVariant(self.hasBalanceCache)
  proc hasBalanceCacheChanged(self: View) {.signal.}
  QtProperty[QVariant] hasBalanceCache:
    read = getHasBalanceCache
    notify = hasBalanceCacheChanged

  proc setHasBalanceCache*(self: View, hasBalanceCache: bool) =
    self.hasBalanceCache = hasBalanceCache
    self.hasBalanceCacheChanged()

  proc getHasMarketValuesCache(self: View): QVariant {.slot.} =
    return newQVariant(self.hasMarketValuesCache)
  proc hasMarketValuesCacheChanged(self: View) {.signal.}
  QtProperty[QVariant] hasMarketValuesCache:
    read = getHasMarketValuesCache
    notify = hasMarketValuesCacheChanged

  proc setHasMarketValuesCache*(self: View, hasMarketValuesCache: bool) =
    self.hasMarketValuesCache = hasMarketValuesCache
    self.hasMarketValuesCacheChanged()

  proc modelsAboutToUpdate*(self: View) =
    self.groupedAccountAssetsModel.modelsAboutToUpdate()

  proc modelsUpdated*(self: View) =
    self.groupedAccountAssetsModel.modelsUpdated()
