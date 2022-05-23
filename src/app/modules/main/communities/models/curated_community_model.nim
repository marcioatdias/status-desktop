import NimQml, Tables
import curated_community_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    Available
    Name
    Description
    Icon
    Featured
    Members
    Popularity
    Color

QtObject:
  type CuratedCommunityModel* = ref object of QAbstractListModel
    items*: seq[CuratedCommunityItem]

  proc setup(self: CuratedCommunityModel) =
    self.QAbstractListModel.setup

  proc delete(self: CuratedCommunityModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc newCuratedCommunityModel*(): CuratedCommunityModel =
    new(result, delete)
    result.setup

  proc countChanged(self: CuratedCommunityModel) {.signal.}

  proc setItems*(self: CuratedCommunityModel, items: seq[CuratedCommunityItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()
    self.countChanged()

  proc getCount(self: CuratedCommunityModel): int {.slot.} =
    self.items.len
  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: CuratedCommunityModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: CuratedCommunityModel): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.Name.int:"name",
      ModelRole.Available.int:"available",
      ModelRole.Description.int:"description",
      ModelRole.Icon.int:"icon",
      ModelRole.Featured.int:"featured",
      ModelRole.Members.int:"members",
      ModelRole.Color.int:"color",
      ModelRole.Popularity.int:"popularity"
    }.toTable

  method data(self: CuratedCommunityModel, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.items.len:
      return
    let item = self.items[index.row]
    let enumRole = role.ModelRole
    case enumRole:
      of ModelRole.Id:
        result = newQVariant(item.getId())
      of ModelRole.Name:
        result = newQVariant(item.getName())
      of ModelRole.Description:
        result = newQVariant(item.getDescription())
      of ModelRole.Available:
        result = newQVariant(item.isAvailable())
      of ModelRole.Icon:
        result = newQVariant(item.getIcon())
      of ModelRole.Members:
        result = newQVariant(item.getMembers())
      of ModelRole.Color:
        result = newQVariant(item.getColor())
      of ModelRole.Popularity:
        # TODO: replace this with a real value
        result = newQVariant(index.row)
      of ModelRole.Featured:
        # TODO: replace this with a real value
        var featured = false
        if index.row < 3:
          featured = true
        result = newQVariant(featured)

  proc findIndexById(self: CuratedCommunityModel, id: string): int =
    for i in 0 ..< self.items.len:
      if(self.items[i].getId() == id):
        return i
    return -1

  proc containsItemWithId*(self: CuratedCommunityModel, id: string): bool =
    return self.findIndexById(id) != -1

  proc removeItemWithId*(self: CuratedCommunityModel, id: string) =
    let ind = self.findIndexById(id)
    if(ind == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, ind, ind)
    self.items.delete(ind)
    self.endRemoveRows()
    self.countChanged()

  proc addItem*(self: CuratedCommunityModel, item: CuratedCommunityItem) =
    let idx = self.findIndexById(item.getId())
    if idx > -1:
      let index = self.createIndex(idx, 0, nil)
      self.items[idx] = item
      self.dataChanged(index, index, @[ModelRole.Name.int,
                                       ModelRole.Available.int,
                                       ModelRole.Description.int,
                                       ModelRole.Icon.int,
                                       ModelRole.Featured.int,
                                       ModelRole.Members.int,
                                       ModelRole.Color.int,
                                       ModelRole.Popularity.int])
    else:
      let parentModelIndex = newQModelIndex()
      defer: parentModelIndex.delete
      self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
      self.items.add(item)
      self.endInsertRows()
      self.countChanged()
    