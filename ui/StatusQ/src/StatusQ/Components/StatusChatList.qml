import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

Column {
    id: statusChatList

    spacing: 4
    width: 288

    property string categoryId: ""
    property string selectedChatId: ""
    property alias chatListItems: statusChatListItems

    property Component popupMenu

    property var filterFn
    property var profileImageFn

    signal chatItemSelected(string id)
    signal chatItemUnmuted(string id)

    onPopupMenuChanged: {
        if (!!popupMenu) {
            popupMenuSlot.sourceComponent = popupMenu
        }
    }

    Repeater {
        id: statusChatListItems
        delegate: StatusChatListItem {

            id: statusChatListItem

            property string profileImage: ""

            Component.onCompleted: {
                if (typeof statusChatList.profileImageFn === "function") {
                    profileImage = statusChatList.profileImageFn(model.chatId || model.id) || ""
                }
            }

            chatId: model.chatId || model.id
            name: model.name
            type: model.chatType
            muted: !!model.muted
            hasUnreadMessages: !!model.hasUnreadMessages
            hasMention: !!model.hasMention
            badge.value: model.unreadMessagesCount || 0
            selected: (model.chatId || model.id) === statusChatList.selectedChatId

            icon.color: model.color || ""
            image.isIdenticon: !!!profileImage && !!!model.identityImage && !!model.identicon
            image.source: profileImage || model.identityImage || model.identicon || ""

            onClicked: {
                if (mouse.button === Qt.RightButton && !!statusChatList.popupMenu) {
                    highlighted = true

                    let originalOpenHandler = popupMenuSlot.item.openHandler
                    let originalCloseHandler = popupMenuSlot.item.closeHandler

                    popupMenuSlot.item.openHandler = function () {
                        if (!!originalOpenHandler) {
                            originalOpenHandler((model.chatId || model.id))
                        }
                    }

                    popupMenuSlot.item.closeHandler = function () {
                        highlighted = false
                        if (!!originalCloseHandler) {
                            originalCloseHandler()
                        }
                    }

                    popupMenuSlot.item.popup(mouse.x + 4, statusChatListItem.y + mouse.y + 6)
                    popupMenuSlot.item.openHandler = originalOpenHandler
                    return
                }
                statusChatList.chatItemSelected(model.chatId || model.id)
            }
            onUnmute: statusChatList.chatItemUnmuted(model.chatId || model.id)
            visible: {
                if (!!statusChatList.filterFn) {
                    return statusChatList.filterFn(model, statusChatList.categoryId)
                }
                return true
            }
        }
    }

    Loader {
        id: popupMenuSlot
        active: !!statusChatList.popupMenu
    }
}
