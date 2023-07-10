import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.panels 1.0
import AppLayouts.Chat.stores 1.0
import StatusQ.Core.Theme 0.1

import Storybook 1.0
import Models 1.0


SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    Logs { id: logs }

    ListModel {
        id: emptyModel
    }

    Button {
        text: "Back"
        onClicked: panel.navigateBack()
    }

    Timer {
        id: feesTimer

        interval: 1000

        onTriggered: {
            panel.isFeeLoading = false
            panel.feeText = "0,0002 ETH (123,15 USD)"
        }
    }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: Theme.palette.statusAppLayout.rightPanelBackgroundColor        

        MintTokensSettingsPanel {
            id: panel

            MintedTokensModel {
                id: mintedTokensModel
            }

            anchors.fill: parent
            anchors.topMargin: 50
            tokensModel: editorModelChecked.checked ? emptyModel : mintedTokensModel
            isAdmin: adminChecked.checked
            isOwner: ownerChecked.checked
            communityLogo: ModelsData.collectibles.doodles
            communityColor: "#FFC4E9"
            communityName: communityNameText.text
            isTokenMasterOwner: masterTokenOwnerChecked.checked
            layer1Networks: NetworksModel.layer1Networks
            layer2Networks: NetworksModel.layer2Networks
            testNetworks: NetworksModel.testNetworks
            enabledNetworks: NetworksModel.enabledNetworks
            allNetworks: enabledNetworks
            accounts: WalletAccountsModel {}
            tokensModelWallet: ListModel {
                ListElement {
                    symbol: "MAI"
                }
            }
            onMintCollectible: logs.logEvent("CommunityMintTokensSettingsPanel::mintCollectible")
            onMintAsset: logs.logEvent("CommunityMintTokensSettingsPanel::mintAssets")
            onDeleteToken: logs.logEvent("CommunityMintTokensSettingsPanel::deleteToken: " + tokenKey)

            onSignMintTransactionOpened: feesTimer.restart()
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ColumnLayout {

            Row {
                Label {
                    text: "Community name: "
                }

                TextEdit {
                    id: communityNameText

                    text: "TEST COMMUNITY"
                }
            }

            CheckBox {
                id: ownerChecked
                checked: true

                text: "Is owner?"
            }

            CheckBox {
                id: masterTokenOwnerChecked
                checked: true

                text: "Is TMaster token owner?"
            }

            CheckBox {
                id: adminChecked
                checked: true

                text: "Is admin?"
            }

            CheckBox {
                id: editorModelChecked
                checked: true

                text: "Empty model"
            }

            RowLayout {
                Button {
                    text: "Set all to 'In progress'"

                    onClicked: mintedTokensModel.changeAllMintingStates(1)
                }
                Button {
                    text: "Set all to 'Deployed'"

                    onClicked: mintedTokensModel.changeAllMintingStates(2)
                }
                Button {
                    text: "Set all to 'Error'"

                    onClicked: mintedTokensModel.changeAllMintingStates(0)
                }
            }
        }
    }
}
