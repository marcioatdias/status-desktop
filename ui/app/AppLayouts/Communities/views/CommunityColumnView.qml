import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls.chat.menuItems 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.views.chat 1.0

import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore

// FIXME: Rework me to use ColumnLayout instead of anchors!!
Item {
    id: root
    objectName: "communityColumnView"
    width: Constants.chatSectionLeftColumnWidth
    height: parent.height

    // Important:
    // We're here in case of CommunitySection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own communitySectionModule)
    property var communitySectionModule
    property var emojiPopup

    property var store
    property var communitiesStore
    required property WalletStore.WalletAssetsStore walletAssetsStore
    required property CurrenciesStore currencyStore
    property bool hasAddedContacts: false
    property var communityData
    property alias createChannelPopup: createChannelPopup

    // Community transfer ownership related props:
    required property bool isPendingOwnershipRequest
    signal finaliseOwnershipClicked

    readonly property bool isSectionAdmin:
        communityData.memberRole === Constants.memberRole.owner ||
        communityData.memberRole === Constants.memberRole.admin ||
        communityData.memberRole === Constants.memberRole.tokenMaster

    readonly property var permissionsModel: {
        root.store.prepareTokenModelForCommunity(communityData.id)
        return root.store.permissionsModel
    }

    signal infoButtonClicked
    signal manageButtonClicked

    QtObject {
        id: d

        readonly property bool showJoinButton: !communityData.joined || root.communityData.amIBanned
        readonly property bool showFinaliseOwnershipButton: root.isPendingOwnershipRequest
        readonly property bool discordImportInProgress: (root.communitiesStore.discordImportProgress > 0 && root.communitiesStore.discordImportProgress < 100)
                                                        || root.communitiesStore.discordImportInProgress

        property bool invitationPending: root.store.isMyCommunityRequestPending(communityData.id)

        property bool joiningCommunityInProgress: false

        onShowJoinButtonChanged: invitationPending = root.store.isMyCommunityRequestPending(communityData.id)
    }

    ColumnHeaderPanel {
        id: communityHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        name: communityData.name
        membersCount: communityData.members.count
        image: communityData.image
        color: communityData.color
        amISectionAdmin: root.isSectionAdmin
        openCreateChat: root.store.openCreateChat
        onInfoButtonClicked: root.infoButtonClicked()
        onAdHocChatButtonClicked: root.store.openCloseCreateChatView()
    }

    Loader {
        id: columnHeaderButton

        anchors.top: communityHeader.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: d.showFinaliseOwnershipButton ? finaliseCommunityOwnershipBtn :
                                                         d.showJoinButton ? joinCommunityButton : undefined
        active: d.showFinaliseOwnershipButton || d.showJoinButton
    }

    ChatsLoadingPanel {
        chatSectionModule: root.communitySectionModule
        width: parent.width
        anchors.top: columnHeaderButton.active ? columnHeaderButton.bottom : communityHeader.bottom
        anchors.topMargin: active ? Style.current.halfPadding : 0
    }

    StatusMenu {
        id: adminPopupMenu
        enabled: root.isSectionAdmin
        hideDisabledItems: !showInviteButton

        property bool showInviteButton: false

        onClosed: adminPopupMenu.showInviteButton = false

        StatusAction {
            objectName: "createCommunityChannelBtn"
            text: qsTr("Create channel")
            icon.name: "channel"
            onTriggered: Global.openPopup(createChannelPopup)
        }

        StatusAction {
            objectName: "importCommunityChannelBtn"
            text: qsTr("Create channel via Discord import")
            icon.name: "download"
            enabled: !d.discordImportInProgress
            onTriggered: {
                Global.openPopup(createChannelPopup, {isDiscordImport: true, communityId: communityData.id})
            }
        }

        StatusAction {
            objectName: "createCommunityCategoryBtn"
            text: qsTr("Create category")
            icon.name: "channel-category"
            onTriggered: Global.openPopup(createCategoryPopup)
        }

        StatusMenuSeparator {
            visible: invitePeopleBtn.enabled
        }

        StatusAction {
            id: invitePeopleBtn
            text: qsTr("Invite people")
            icon.name: "share-ios"
            enabled: communityData.canManageUsers && adminPopupMenu.showInviteButton
            objectName: "invitePeople"
            onTriggered: {
                Global.openInviteFriendsToCommunityPopup(root.communityData,
                                                         root.communitySectionModule,
                                                         null)
            }
        }
    }

    StatusScrollView {
        id: scrollView

        anchors.top: columnHeaderButton.active ? columnHeaderButton.bottom : communityHeader.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.bottom: createChatOrCommunity.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        contentWidth: availableWidth
        contentHeight: communityChatListAndCategories.height
                       + bannerColumn.height
                       + bannerColumn.anchors.topMargin

        StatusChatListAndCategories {
            id: communityChatListAndCategories
            width: scrollView.availableWidth
            draggableItems: root.isSectionAdmin
            draggableCategories: root.isSectionAdmin

            model: root.communitySectionModule.model
            highlightItem: !root.store.openCreateChat

            onChatItemSelected: {
                Global.closeCreateChatView()
                root.communitySectionModule.setActiveItem(id)
            }

            showCategoryActionButtons: root.isSectionAdmin
            showPopupMenu: root.isSectionAdmin && communityData.canManageUsers

            onChatItemUnmuted: root.communitySectionModule.unmuteChat(id)
            onChatItemReordered: function(categoryId, chatId, to) {
                root.store.reorderCommunityChat(categoryId, chatId, to);
            }
            onChatListCategoryReordered: root.store.reorderCommunityCategories(categoryId, to)

            onCategoryAddButtonClicked: Global.openPopup(createChannelPopup, {
                                                             categoryId: id
                                                         })

            popupMenu: StatusMenu {
                hideDisabledItems: false
                StatusAction {
                    text: qsTr("Create channel")
                    icon.name: "channel"
                    enabled: root.isSectionAdmin
                    onTriggered: Global.openPopup(createChannelPopup)
                }

                StatusAction {
                    objectName: "importCommunityChannelBtn"
                    text: qsTr("Create channel via Discord import")
                    icon.name: "download"
                    enabled: !d.discordImportInProgress
                    onTriggered: Global.openPopup(createChannelPopup, {isDiscordImport: true, communityId: root.communityData.id})
                }

                StatusAction {
                    text: qsTr("Create category")
                    icon.name: "channel-category"
                    enabled: root.isSectionAdmin
                    onTriggered: Global.openPopup(createCategoryPopup)
                }

                StatusMenuSeparator {}

                StatusAction {
                    text: qsTr("Invite people")
                    icon.name: "share-ios"
                    enabled: communityData.canManageUsers
                    objectName: "invitePeople"
                    onTriggered: {
                        Global.openInviteFriendsToCommunityPopup(root.communityData,
                                                                 root.communitySectionModule,
                                                                 null)
                    }
                }
            }

            categoryPopupMenu: StatusMenu {
                id: contextMenuCategory
                property var categoryItem

                MuteChatMenuItem {
                    enabled: !!categoryItem && !categoryItem.muted
                    title: qsTr("Mute category")
                    onMuteTriggered: {
                        root.communitySectionModule.muteCategory(categoryItem.itemId, interval)
                        contextMenuCategory.close()
                    }
                }

                StatusAction {
                    enabled: !!categoryItem && categoryItem.muted
                    text: qsTr("Unmute category")
                    icon.name: "notification"
                    onTriggered: {
                        root.communitySectionModule.unmuteCategory(categoryItem.itemId)
                    }
                }

                StatusAction {
                    objectName: "editCategoryMenuItem"
                    enabled: root.isSectionAdmin
                    text: qsTr("Edit Category")
                    icon.name: "edit"
                    onTriggered: {
                        Global.openPopup(createCategoryPopup, {
                                             isEdit: true,
                                             channels: [],
                                             categoryId: categoryItem.itemId,
                                             categoryName: categoryItem.name
                                         })
                    }
                }

                StatusMenuSeparator {
                    visible: root.isSectionAdmin
                }

                StatusAction {
                    objectName: "deleteCategoryMenuItem"
                    enabled: root.isSectionAdmin
                    text: qsTr("Delete Category")
                    icon.name: "delete"
                    type: StatusAction.Type.Danger
                    onTriggered: {
                        Global.openPopup(deleteCategoryConfirmationDialogComponent, {
                                             "headerSettings.title": qsTr("Delete '%1' category").arg(categoryItem.name),
                                             confirmationText: qsTr("Are you sure you want to delete '%1' category? Channels inside the category won't be deleted.")
                                             .arg(categoryItem.name),
                                             categoryId: categoryItem.itemId
                                         })
                    }
                }
            }

            chatListPopupMenu: ChatContextMenuView {
                id: chatContextMenuView
                showDebugOptions: root.store.isDebugEnabledfir

                // TODO pass the chatModel in its entirety instead of fetching the JSOn using just the id
                openHandler: function (id) {
                    try {
                        let jsonObj = root.communitySectionModule.getItemAsJson(id)
                        let obj = JSON.parse(jsonObj)
                        if (obj.error) {
                            console.error("error parsing chat item json object, id: ", id, " error: ", obj.error)
                            close()
                            return
                        }

                        currentFleet = root.communitySectionModule.getCurrentFleet()
                        isCommunityChat = root.communitySectionModule.isCommunity()
                        amIChatAdmin = root.isSectionAdmin
                        chatId = obj.itemId
                        chatName = obj.name
                        chatDescription = obj.description
                        chatIcon = obj.icon
                        chatEmoji = obj.emoji
                        chatColor = obj.color
                        chatType = obj.type
                        chatMuted = obj.muted
                        channelPosition = obj.position
                        chatCategoryId = obj.categoryId
                        viewersCanPostReactions = obj.viewersCanPostReactions
                        hideIfPermissionsNotMet = obj.hideIfPermissionsNotMet
                    } catch (e) {
                        console.error("error parsing chat item json object, id: ", id, " error: ", e)
                        close()
                        return
                    }
                }

                onMuteChat: {
                    root.communitySectionModule.muteChat(chatId, interval)
                }

                onUnmuteChat: {
                    root.communitySectionModule.unmuteChat(chatId)
                }

                onMarkAllMessagesRead: {
                    root.communitySectionModule.markAllMessagesRead(chatId)
                }

                onRequestMoreMessages: {
                    root.communitySectionModule.requestMoreMessages(chatId)
                }

                onClearChatHistory: {
                    root.communitySectionModule.clearChatHistory(chatId)
                }

                onRequestAllHistoricMessages: {
                    // Not Refactored Yet - Check in the `master` branch if this is applicable here.
                }

                onLeaveChat: {
                    root.communitySectionModule.leaveChat(chatId)
                }

                onDeleteCommunityChat:  root.store.removeCommunityChat(chatId)

                onDownloadMessages: {
                    root.communitySectionModule.downloadMessages(chatId, file)
                }

                onDisplayProfilePopup: {
                    Global.openProfilePopup(publicKey)
                }
                onDisplayEditChannelPopup: {
                    Global.openPopup(createChannelPopup, {
                        isEdit: true,
                        channelName: chatName,
                        channelDescription: chatDescription,
                        channelEmoji: chatEmoji,
                        channelColor: chatColor,
                        categoryId: chatCategoryId,
                        chatId: chatContextMenuView.chatId,
                        channelPosition: channelPosition,
                        viewOnlyCanAddReaction: viewersCanPostReactions,
                        deleteChatConfirmationDialog: deleteChatConfirmationDialog,
                        hideIfPermissionsNotMet: hideIfPermissionsNotMet
                    });
                }
            }
        }

        Column {
            id: bannerColumn
            width: scrollView.availableWidth
            anchors.top: communityChatListAndCategories.bottom
            anchors.topMargin: Style.current.padding
            spacing: Style.current.bigPadding

            Loader {
                active: root.isSectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityWelcomeBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityWelcomeBanners.includes(communityData.id))
                width: parent.width
                height: item.height
                sourceComponent: Component {
                    WelcomeBannerPanel {
                        activeCommunity: communityData
                        store: root.store
                        hasAddedContacts: root.hasAddedContacts
                        communitySectionModule: root.communitySectionModule
                        onManageCommunityClicked: root.manageButtonClicked()
                    }
                }
            } // Loader

            Loader {
                active: root.isSectionAdmin &&
                        (!localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners ||
                         !localAccountSensitiveSettings.hiddenCommunityChannelAndCategoriesBanners.includes(communityData.id))
                width: parent.width
                height: item.height
                sourceComponent: Component {
                    ChannelsAndCategoriesBannerPanel {
                        id: channelsAndCategoriesBanner
                        communityId: communityData.id
                        onAddMembersClicked: {
                            Global.openPopup(createChannelPopup);
                        }
                        onAddCategoriesClicked: {
                            Global.openPopup(createCategoryPopup);
                        }
                    }
                }
            } // Loader
        } // Column

        background: Item {
            TapHandler {
                enabled: root.isSectionAdmin
                acceptedButtons: Qt.RightButton
                onTapped: {
                    adminPopupMenu.showInviteButton = true
                    adminPopupMenu.x = eventPoint.position.x + 4
                    adminPopupMenu.y = eventPoint.position.y + 4
                    adminPopupMenu.open()
                }
            }
        }
    } // ScrollView

    Loader {
        id: createChatOrCommunity
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: active ? Style.current.padding : 0
        active: root.isSectionAdmin
        sourceComponent: Component {
            StatusLinkText {
                id: createChannelOrCategoryBtn
                objectName: "createChannelOrCategoryBtn"
                height: visible ? implicitHeight : 0
                text: qsTr("Create channel or category")
                font.underline: true

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        adminPopupMenu.showInviteButton = false
                        adminPopupMenu.popup()
                        adminPopupMenu.y = Qt.binding(() => root.height - adminPopupMenu.height
                                                      - createChannelOrCategoryBtn.height - 20)
                    }
                }
            }
        }
    }

    Component {
        id: joinCommunityButton

        StatusButton {
            anchors.top: communityHeader.bottom
            anchors.topMargin: Style.current.halfPadding
            anchors.bottomMargin: Style.current.halfPadding
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: !root.communityData.amIBanned
            loading: d.joiningCommunityInProgress

            text: {
                if (root.communityData.amIBanned) return qsTr("You were banned from community")
                if (d.invitationPending) return qsTr("Membership request pending...")

                return root.communityData.access === Constants.communityChatOnRequestAccess ?
                            qsTr("Request to join") : qsTr("Join Community")
            }

            onClicked: {
                Global.openPopup(communityMembershipSetupDialogComponent);
            }

            Connections {
                enabled: d.joiningCommunityInProgress
                target: root.store.communitiesModuleInst
                function onCommunityAccessRequested(communityId: string) {
                    if (communityId === communityData.id) {
                        d.invitationPending = root.store.isMyCommunityRequestPending(communityData.id)
                        d.joiningCommunityInProgress = false
                    }
                }

                function onCommunityAccessFailed(communityId: string, error: string) {
                    if (communityId === communityData.id) {
                        d.invitationPending = false
                        d.joiningCommunityInProgress = false
                        Global.displayToastMessage(qsTr("Request to join failed"),
                                                   qsTr("Please try again later"),
                                                   "",
                                                   false,
                                                   Constants.ephemeralNotificationType.normal,
                                                   "")
                    }
                }
            }

            Component {
                id: communityMembershipSetupDialogComponent

                CommunityMembershipSetupDialog {
                    id: dialogRoot

                    isInvitationPending: d.invitationPending
                    requirementsCheckPending: root.store.requirementsCheckPending
                    communityName: communityData.name
                    introMessage: communityData.introMessage
                    communityIcon: communityData.image
                    accessType: communityData.access

                    walletAccountsModel: WalletStore.RootStore.nonWatchAccounts
                    canProfileProveOwnershipOfProvidedAddressesFn: WalletStore.RootStore.canProfileProveOwnershipOfProvidedAddresses

                    walletAssetsModel: walletAssetsStore.groupedAccountAssetsModel
                    permissionsModel: {
                        root.store.prepareTokenModelForCommunity(communityData.id)
                        return root.store.permissionsModel
                    }
                    assetsModel: root.store.assetsModel
                    collectiblesModel: root.store.collectiblesModel

                    getCurrencyAmount: function (balance, symbol){
                        return currencyStore.getCurrencyAmount(balance, symbol)
                    }

                    onPrepareForSigning: {
                        root.store.prepareKeypairsForSigning(communityData.id, root.store.userProfileInst.name, sharedAddresses, airdropAddress, false)

                        dialogRoot.keypairSigningModel = root.store.communitiesModuleInst.keypairsSigningModel
                    }

                    onSignProfileKeypairAndAllNonKeycardKeypairs: {
                        root.store.signProfileKeypairAndAllNonKeycardKeypairs()
                    }

                    onSignSharedAddressesForKeypair: {
                        root.store.signSharedAddressesForKeypair(keyUid)
                    }

                    onJoinCommunity: {
                        d.joiningCommunityInProgress = true
                        root.store.joinCommunityOrEditSharedAddresses()
                    }

                    onCancelMembershipRequest: {
                        root.store.cancelPendingRequest(communityData.id)
                        d.invitationPending = root.store.isMyCommunityRequestPending(communityData.id)
                    }

                    onSharedAddressesUpdated: {
                        root.store.updatePermissionsModel(communityData.id, sharedAddresses)
                    }

                    onClosed: {
                        destroy()
                    }

                    Connections {
                        target: root.store.communitiesModuleInst

                        function onAllSharedAddressesSigned() {
                            if (dialogRoot.profileProvesOwnershipOfSelectedAddresses) {
                                dialogRoot.joinCommunity()
                                dialogRoot.close()
                                return
                            }

                            if (dialogRoot.allAddressesToRevealBelongToSingleNonProfileKeypair) {
                                dialogRoot.joinCommunity()
                                dialogRoot.close()
                                return
                            }

                            if (!!dialogRoot.replaceItem) {
                                dialogRoot.replaceLoader.item.allSigned()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: finaliseCommunityOwnershipBtn

        StatusButton {
            anchors.top: communityHeader.bottom
            anchors.topMargin: Style.current.halfPadding
            anchors.bottomMargin: Style.current.halfPadding
            anchors.horizontalCenter: parent.horizontalCenter

            text: communityData.joined ? qsTr("Finalise community ownership") : qsTr("To join, finalise community ownership")

            onClicked: root.finaliseOwnershipClicked()
        }
    }

    Component {
        id: createChannelPopup
        CreateChannelPopup {
            communitiesStore: root.communitiesStore
            assetsModel: root.store.assetsModel
            collectiblesModel: root.store.collectiblesModel
            permissionsModel: root.store.permissionsModel
            channelsModel: root.store.chatCommunitySectionModule.model
            emojiPopup: root.emojiPopup
            activeCommunity: root.communityData

            property int channelPosition: -1
            property var deleteChatConfirmationDialog

            onCreateCommunityChannel: function (chName, chDescription, chEmoji, chColor,
                                                chCategoryId, hideIfPermissionsNotMet) {
                root.store.createCommunityChannel(chName, chDescription, chEmoji, chColor,
                                                  chCategoryId, viewOnlyCanAddReaction, hideIfPermissionsNotMet)
                chatId = root.store.currentChatContentModule().chatDetails.id
            }
            onEditCommunityChannel: {
                root.store.editCommunityChannel(chatId,
                                                chName,
                                                chDescription,
                                                chEmoji,
                                                chColor,
                                                chCategoryId,
                                                channelPosition,
                                                viewOnlyCanAddReaction,
                                                hideIfPermissionsNotMet);
            }

            onAddPermissions: function (permissions) {
                for (var i = 0; i < permissions.length; i++) {
                    root.store.permissionsStore.createPermission(permissions[i].holdingsListModel,
                                                                permissions[i].permissionType,
                                                                permissions[i].isPrivate,
                                                                permissions[i].channelsListModel)
                }
            }
            onRemovePermissions: function (permissions) {
                for (var i = 0; i < permissions.length; i++) {
                    root.store.permissionsStore.removePermission(permissions[i].id)
                }
            }
            onEditPermissions: function (permissions) {
                for (var i = 0; i < permissions.length; i++) {
                    root.store.permissionsStore.editPermission(permissions[i].id,
                                                                permissions[i].holdingsListModel,
                                                                permissions[i].permissionType,
                                                                permissions[i].channelsListModel,
                                                                permissions[i].isPrivate)
                }
            }
            onSetHideIfPermissionsNotMet: function (checked) {
                root.store.permissionsStore.setHideIfPermissionsNotMet(chatId, checked)
            }
            onDeleteCommunityChannel: {
                Global.openPopup(deleteChatConfirmationDialog);
                close()
            }
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: createCategoryPopup
        CreateCategoryPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: deleteCategoryConfirmationDialogComponent
        ConfirmationDialog {
            property string categoryId
            confirmButtonObjectName: "confirmDeleteCategoryButton"
            showCancelButton: true
            onClosed: {
                destroy()
            }
            onCancelButtonClicked: {
                close();
            }
            onConfirmButtonClicked: function(){
                const error = root.store.deleteCommunityCategory(categoryId);
                if (error) {
                    deleteError.text = error
                    return deleteError.open()
                }
                close();
            }
        }
    }

    MessageDialog {
        id: deleteError
        title: qsTr("Error deleting the category")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}
