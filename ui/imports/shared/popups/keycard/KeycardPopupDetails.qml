import QtQuick 2.14

import StatusQ.Controls 0.1

import utils 1.0

QtObject {
    id: root

    property var sharedKeycardModule

    property bool primaryButtonEnabled: false
    readonly property bool disablePopupClose: {
        switch (root.sharedKeycardModule.currentState.stateType) {

        case Constants.keycardSharedState.readingKeycard:
        case Constants.keycardSharedState.recognizedKeycard:
        case Constants.keycardSharedState.renamingKeycard:
        case Constants.keycardSharedState.changingKeycardPin:
        case Constants.keycardSharedState.changingKeycardPuk:
        case Constants.keycardSharedState.changingKeycardPairingCode:
        case Constants.keycardSharedState.migratingKeyPair:
        case Constants.keycardSharedState.copyingKeycard:
            return true

        case Constants.keycardSharedState.keyPairMigrateSuccess:
            return root.sharedKeycardModule.migratingProfileKeyPair()
        }

        return false
    }

    property list<Item> leftButtons: [
        StatusBackButton {
            id: backButton
            visible: root.sharedKeycardModule.currentState.displayBackButton
            height: Constants.keycard.general.footerButtonsHeight
            width: height
            onClicked: {
                root.sharedKeycardModule.currentState.doBackAction()
            }
        }
    ]

    property list<StatusBaseButton> rightButtons: [
        StatusButton {
            id: cancelButton
            height: Constants.keycard.general.footerButtonsHeight
            text: qsTr("Cancel")
            visible: {
                switch (root.sharedKeycardModule.currentState.flowType) {

                case Constants.keycardSharedFlow.setupNewKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.selectExistingKeyPair:
                    case Constants.keycardSharedState.keycardNotEmpty:
                    case Constants.keycardSharedState.keycardEmptyMetadata:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                    case Constants.keycardSharedState.factoryResetConfirmation:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                    case Constants.keycardSharedState.factoryResetSuccess:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.factoryReset:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                    case Constants.keycardSharedState.keycardEmptyMetadata:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                    case Constants.keycardSharedState.factoryResetConfirmation:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.authentication:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.wrongKeychainPin:
                    case Constants.keycardSharedState.biometricsReadyToSign:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.enterPassword:
                    case Constants.keycardSharedState.wrongPassword:
                    case Constants.keycardSharedState.biometricsPasswordFailed:
                    case Constants.keycardSharedState.biometricsPinFailed:
                    case Constants.keycardSharedState.biometricsPinInvalid:
                    case Constants.keycardSharedState.enterBiometricsPassword:
                    case Constants.keycardSharedState.wrongBiometricsPassword:
                    case Constants.keycardSharedState.enterPin:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.unlockKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.enterPuk:
                    case Constants.keycardSharedState.wrongPuk:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.unlockKeycardOptions:
                    case Constants.keycardSharedState.enterSeedPhrase:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.displayKeycardContent:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.renameKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.changeKeycardPin:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.createPin:
                    case Constants.keycardSharedState.repeatPin:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.changeKeycardPuk:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.createPuk:
                    case Constants.keycardSharedState.repeatPuk:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.changePairingCode:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.createPairingCode:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return true
                    }
                    break

                case Constants.keycardSharedFlow.createCopyOfAKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                    case Constants.keycardSharedState.removeKeycard:
                    case Constants.keycardSharedState.sameKeycard:
                    case Constants.keycardSharedState.copyToKeycard:
                    case Constants.keycardSharedState.enterSeedPhrase:
                    case Constants.keycardSharedState.wrongSeedPhrase:
                    case Constants.keycardSharedState.keycardNotEmpty:
                        return true

                    case Constants.keycardSharedState.keycardEmptyMetadata:
                        let copyFromAKeycardPartDone = root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.copyFromAKeycardPartDone
                        if (copyFromAKeycardPartDone) {
                            return true
                        }
                        break
                    }
                    break
                }

                return false
            }
            enabled: {
                switch (root.sharedKeycardModule.currentState.stateType) {

                case Constants.keycardSharedState.readingKeycard:
                case Constants.keycardSharedState.migratingKeyPair:
                case Constants.keycardSharedState.renamingKeycard:
                case Constants.keycardSharedState.changingKeycardPin:
                case Constants.keycardSharedState.changingKeycardPuk:
                case Constants.keycardSharedState.changingKeycardPairingCode:
                case Constants.keycardSharedState.copyingKeycard:
                    if (root.disablePopupClose) {
                        return false
                    }
                }

                return true
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doCancelAction()
            }
        },

        StatusButton {
            id: secondaryButton
            height: Constants.keycard.general.footerButtonsHeight
            text: {
                switch (root.sharedKeycardModule.currentState.flowType) {

                case Constants.keycardSharedFlow.authentication:
                    if (userProfile.usingBiometricLogin) {

                        switch (root.sharedKeycardModule.currentState.stateType) {

                        case Constants.keycardSharedState.enterPassword:
                        case Constants.keycardSharedState.wrongPassword:
                            return qsTr("Use biometrics instead")

                        case Constants.keycardSharedState.biometricsPasswordFailed:
                            return qsTr("Use password instead")

                        case Constants.keycardSharedState.enterPin:
                        case Constants.keycardSharedState.wrongPin:
                            return qsTr("Use biometrics")

                        case Constants.keycardSharedState.pluginReader:
                        case Constants.keycardSharedState.insertKeycard:
                        case Constants.keycardSharedState.keycardInserted:
                        case Constants.keycardSharedState.readingKeycard:
                        case Constants.keycardSharedState.biometricsReadyToSign:
                        case Constants.keycardSharedState.notKeycard:
                        case Constants.keycardSharedState.biometricsPinFailed:
                        case Constants.keycardSharedState.wrongKeycard:
                        case Constants.keycardSharedState.keycardEmpty:
                            return qsTr("Use PIN")

                        case Constants.keycardSharedState.biometricsPinInvalid:
                            return qsTr("Update PIN")
                        }
                    }
                    break

                case Constants.keycardSharedFlow.unlockKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.unlockKeycardOptions:
                        return qsTr("Unlock using PUK")
                    }
                    break
                }

                return ""
            }

            visible: text !== ""
            enabled: {
                switch (root.sharedKeycardModule.currentState.stateType) {

                case Constants.keycardSharedState.readingKeycard:
                case Constants.keycardSharedState.migratingKeyPair:
                case Constants.keycardSharedState.renamingKeycard:
                case Constants.keycardSharedState.changingKeycardPin:
                case Constants.keycardSharedState.changingKeycardPuk:
                case Constants.keycardSharedState.changingKeycardPairingCode:
                case Constants.keycardSharedState.copyingKeycard:
                    if (root.disablePopupClose) {
                        return false
                    }
                }

                switch (root.sharedKeycardModule.currentState.flowType) {

                case Constants.keycardSharedFlow.authentication:
                    if (userProfile.usingBiometricLogin) {
                        switch (root.sharedKeycardModule.currentState.stateType) {
                        case Constants.keycardSharedState.pluginReader:
                        case Constants.keycardSharedState.insertKeycard:
                        case Constants.keycardSharedState.keycardInserted:
                        case Constants.keycardSharedState.readingKeycard:
                        case Constants.keycardSharedState.notKeycard:
                        case Constants.keycardSharedState.wrongKeycard:
                        case Constants.keycardSharedState.keycardEmpty:
                            return false
                        }
                    }
                    break

                case Constants.keycardSharedFlow.unlockKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {
                    case Constants.keycardSharedState.unlockKeycardOptions:
                        return root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.offerPukForUnlock
                    }
                    break
                }

                return true
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doSecondaryAction()
            }
        },

        StatusButton {
            id: primaryButton
            objectName: "PrimaryButton"
            height: Constants.keycard.general.footerButtonsHeight
            text: {
                switch (root.sharedKeycardModule.currentState.flowType) {

                case Constants.keycardSharedFlow.setupNewKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.createPin:
                    case Constants.keycardSharedState.repeatPin:
                    case Constants.keycardSharedState.pinSet:
                        return qsTr("Input seed phrase")

                    case Constants.keycardSharedState.seedPhraseEnterWords:
                        return qsTr("Yes, migrate key pair to this Keycard")

                    case Constants.keycardSharedState.enterSeedPhrase:
                        return qsTr("Yes, migrate key pair to Keycard")

                    case Constants.keycardSharedState.wrongSeedPhrase:
                        return qsTr("Try entering seed phrase again")

                    case Constants.keycardSharedState.keycardNotEmpty:
                        return qsTr("Check what is stored on this Keycard")

                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                        return qsTr("I don’t know the PIN")

                    case Constants.keycardSharedState.factoryResetConfirmation:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                        return qsTr("Factory reset this Keycard")

                    case Constants.keycardSharedState.selectExistingKeyPair:
                    case Constants.keycardSharedState.keycardEmptyMetadata:
                    case Constants.keycardSharedState.factoryResetSuccess:
                    case Constants.keycardSharedState.seedPhraseDisplay:
                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                        return qsTr("Next")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        if (root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.useUnlockLabelForLockedState)
                            return qsTr("Unlock Keycard")
                        return qsTr("Next")

                    case Constants.keycardSharedState.migratingKeyPair:
                    case Constants.keycardSharedState.keyPairMigrateFailure:
                        return qsTr("Done")

                    case Constants.keycardSharedState.keyPairMigrateSuccess:
                        if (root.sharedKeycardModule.migratingProfileKeyPair())
                            return qsTr("Restart app & sign in using your new Keycard")
                        return qsTr("Done")

                    }
                    break

                case Constants.keycardSharedFlow.factoryReset:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                        return qsTr("I don’t know the PIN")

                    case Constants.keycardSharedState.factoryResetConfirmation:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                        return qsTr("Factory reset this Keycard")

                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                    case Constants.keycardSharedState.keycardEmptyMetadata:
                        return qsTr("Next")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")

                    case Constants.keycardSharedState.keycardEmpty:
                    case Constants.keycardSharedState.factoryResetSuccess:
                        return qsTr("Done")
                    }
                    break

                case Constants.keycardSharedFlow.authentication:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.biometricsReadyToSign:
                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.enterPassword:
                    case Constants.keycardSharedState.wrongPassword:
                    case Constants.keycardSharedState.enterPin:
                        return qsTr("Authenticate")

                    case Constants.keycardSharedState.keycardEmpty:
                        return qsTr("Done")

                    case Constants.keycardSharedState.enterBiometricsPassword:
                    case Constants.keycardSharedState.wrongBiometricsPassword:
                        return qsTr("Update password & authenticate")

                    case Constants.keycardSharedState.wrongKeychainPin:
                        return qsTr("Update PIN & authenticate")

                    case Constants.keycardSharedState.biometricsPasswordFailed:
                    case Constants.keycardSharedState.biometricsPinFailed:
                    case Constants.keycardSharedState.biometricsPinInvalid:
                        return qsTr("Try biometrics again")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")

                    }
                    break

                case Constants.keycardSharedFlow.unlockKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.keycardEmpty:
                    case Constants.keycardSharedState.keycardAlreadyUnlocked:
                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.unlockKeycardSuccess:
                        return qsTr("Done")

                    case Constants.keycardSharedState.unlockKeycardOptions:
                        return qsTr("Unlock using seed phrase")

                    case Constants.keycardSharedState.createPin:
                    case Constants.keycardSharedState.repeatPin:
                    case Constants.keycardSharedState.pinSet:
                    case Constants.keycardSharedState.enterSeedPhrase:
                    case Constants.keycardSharedState.enterPuk:
                    case Constants.keycardSharedState.wrongPuk:
                        return qsTr("Next")

                    case Constants.keycardSharedState.wrongSeedPhrase:
                        return qsTr("Try entering seed phrase again")

                    case Constants.keycardSharedState.maxPukRetriesReached:
                        return qsTr("Unlock Keycard")

                    }
                    break

                case Constants.keycardSharedFlow.displayKeycardContent:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.keycardEmpty:
                    case Constants.keycardSharedState.keycardEmptyMetadata:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                        return qsTr("Done")

                    case Constants.keycardSharedState.wrongPin:
                        return qsTr("I don’t know the PIN")

                    case Constants.keycardSharedState.pinVerified:
                        return qsTr("Next")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")

                    }
                    break

                case Constants.keycardSharedFlow.renameKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.keycardEmptyMetadata:
                    case Constants.keycardSharedState.keycardRenameSuccess:
                    case Constants.keycardSharedState.keycardRenameFailure:
                    case Constants.keycardSharedState.renamingKeycard:
                        return qsTr("Done")

                    case Constants.keycardSharedState.wrongPin:
                        return qsTr("I don’t know the PIN")

                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                        return qsTr("Next")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")

                    case Constants.keycardSharedState.enterKeycardName:
                        return qsTr("Rename this Keycard")
                    }
                    break

                case Constants.keycardSharedFlow.changeKeycardPin:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.changingKeycardPin:
                    case Constants.keycardSharedState.changingKeycardPinSuccess:
                    case Constants.keycardSharedState.changingKeycardPinFailure:
                        return qsTr("Done")

                    case Constants.keycardSharedState.wrongPin:
                        return qsTr("I don’t know the PIN")

                    case Constants.keycardSharedState.pinVerified:
                        return qsTr("Next")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")
                    }
                    break

                case Constants.keycardSharedFlow.changeKeycardPuk:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.changingKeycardPuk:
                    case Constants.keycardSharedState.changingKeycardPukSuccess:
                    case Constants.keycardSharedState.changingKeycardPukFailure:
                        return qsTr("Done")

                    case Constants.keycardSharedState.wrongPin:
                        return qsTr("I don’t know the PIN")

                    case Constants.keycardSharedState.pinVerified:
                        return qsTr("Next")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")
                    }
                    break

                case Constants.keycardSharedFlow.changePairingCode:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.changingKeycardPairingCode:
                    case Constants.keycardSharedState.changingKeycardPairingCodeSuccess:
                    case Constants.keycardSharedState.changingKeycardPairingCodeFailure:
                        return qsTr("Done")

                    case Constants.keycardSharedState.wrongPin:
                        return qsTr("I don’t know the PIN")

                    case Constants.keycardSharedState.pinVerified:
                        return qsTr("Next")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")

                    case Constants.keycardSharedState.createPairingCode:
                        return qsTr("Set paring code")
                    }
                    break

                case Constants.keycardSharedFlow.createCopyOfAKeycard:
                    let copyFromAKeycardPartDone = root.sharedKeycardModule.keycardData & Constants.predefinedKeycardData.copyFromAKeycardPartDone
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.enterPin:
                    case Constants.keycardSharedState.wrongPin:
                        if (copyFromAKeycardPartDone) {
                            return qsTr("I don’t know the PIN")
                        }
                        break

                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.keycardEmpty:
                    case Constants.keycardSharedState.copyingKeycard:
                    case Constants.keycardSharedState.copyingKeycardSuccess:
                    case Constants.keycardSharedState.copyingKeycardFailure:
                        return qsTr("Done")

                    case Constants.keycardSharedState.pinVerified:
                    case Constants.keycardSharedState.keycardMetadataDisplay:
                    case Constants.keycardSharedState.removeKeycard:
                    case Constants.keycardSharedState.factoryResetSuccess:
                    case Constants.keycardSharedState.copyToKeycard:
                    case Constants.keycardSharedState.enterSeedPhrase:
                        return qsTr("Next")

                    case Constants.keycardSharedState.keycardEmptyMetadata:
                        if (copyFromAKeycardPartDone) {
                            return qsTr("Next")
                        }
                        return qsTr("Done")

                    case Constants.keycardSharedState.wrongSeedPhrase:
                        return qsTr("Try entering seed phrase again")

                    case Constants.keycardSharedState.maxPinRetriesReached:
                    case Constants.keycardSharedState.maxPukRetriesReached:
                    case Constants.keycardSharedState.maxPairingSlotsReached:
                        return qsTr("Unlock Keycard")

                    case Constants.keycardSharedState.sameKeycard:
                        return qsTr("Try inserting a different Keycard")

                    case Constants.keycardSharedState.notKeycard:
                        if (copyFromAKeycardPartDone) {
                            return qsTr("Try inserting a different Keycard")
                        }
                        break

                    case Constants.keycardSharedState.keycardNotEmpty:
                        return qsTr("Check what is stored on this Keycard")

                    case Constants.keycardSharedState.factoryResetConfirmation:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                        return qsTr("Factory reset this Keycard")
                    }
                    break
                }

                return ""
            }
            visible: text !== ""
            enabled: {
                switch (root.sharedKeycardModule.currentState.stateType) {

                case Constants.keycardSharedState.readingKeycard:
                case Constants.keycardSharedState.migratingKeyPair:
                case Constants.keycardSharedState.renamingKeycard:
                case Constants.keycardSharedState.changingKeycardPin:
                case Constants.keycardSharedState.changingKeycardPuk:
                case Constants.keycardSharedState.changingKeycardPairingCode:
                case Constants.keycardSharedState.copyingKeycard:
                    if (root.disablePopupClose) {
                        return false
                    }
                }

                switch (root.sharedKeycardModule.currentState.flowType) {
                case Constants.keycardSharedFlow.setupNewKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.selectExistingKeyPair:
                    case Constants.keycardSharedState.factoryResetConfirmation:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                    case Constants.keycardSharedState.seedPhraseDisplay:
                    case Constants.keycardSharedState.seedPhraseEnterWords:
                    case Constants.keycardSharedState.enterSeedPhrase:
                        return root.primaryButtonEnabled

                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.recognizedKeycard:
                    case Constants.keycardSharedState.createPin:
                    case Constants.keycardSharedState.repeatPin:
                        return false
                    }
                    break

                case Constants.keycardSharedFlow.factoryReset:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.factoryResetConfirmation:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                        return root.primaryButtonEnabled
                    }
                    break

                case Constants.keycardSharedFlow.authentication:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.pluginReader:
                    case Constants.keycardSharedState.readingKeycard:
                    case Constants.keycardSharedState.insertKeycard:
                    case Constants.keycardSharedState.keycardInserted:
                    case Constants.keycardSharedState.wrongPin:
                    case Constants.keycardSharedState.wrongKeychainPin:
                    case Constants.keycardSharedState.notKeycard:
                    case Constants.keycardSharedState.wrongKeycard:
                    case Constants.keycardSharedState.enterPassword:
                    case Constants.keycardSharedState.wrongPassword:
                    case Constants.keycardSharedState.enterBiometricsPassword:
                    case Constants.keycardSharedState.wrongBiometricsPassword:
                    case Constants.keycardSharedState.enterPin:
                        return root.primaryButtonEnabled
                    }
                    break

                case Constants.keycardSharedFlow.unlockKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.enterSeedPhrase:
                    case Constants.keycardSharedState.enterPuk:
                    case Constants.keycardSharedState.wrongPuk:
                        return root.primaryButtonEnabled

                    case Constants.keycardSharedState.createPin:
                    case Constants.keycardSharedState.repeatPin:
                        return false
                    }
                    break

                case Constants.keycardSharedFlow.renameKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.enterKeycardName:
                        return root.primaryButtonEnabled
                    }
                    break

                case Constants.keycardSharedFlow.changePairingCode:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.createPairingCode:
                        return root.primaryButtonEnabled
                    }
                    break

                case Constants.keycardSharedFlow.createCopyOfAKeycard:
                    switch (root.sharedKeycardModule.currentState.stateType) {

                    case Constants.keycardSharedState.factoryResetConfirmation:
                    case Constants.keycardSharedState.factoryResetConfirmationDisplayMetadata:
                    case Constants.keycardSharedState.enterSeedPhrase:
                        return root.primaryButtonEnabled
                    }
                    break
                }

                return true
            }

            icon.name: {
                switch (root.sharedKeycardModule.currentState.flowType) {
                case Constants.keycardSharedFlow.setupNewKeycard:
                    if (root.sharedKeycardModule.migratingProfileKeyPair()) {
                        switch (root.sharedKeycardModule.currentState.stateType) {

                        case Constants.keycardSharedState.seedPhraseEnterWords:
                        case Constants.keycardSharedState.enterSeedPhrase:
                            if (userProfile.usingBiometricLogin)
                                return "touch-id"
                            if (userProfile.isKeycardUser)
                                return "keycard"
                            return "password"
                        }
                    }
                    break

                case Constants.keycardSharedFlow.authentication:
                    if (userProfile.usingBiometricLogin) {
                        switch (root.sharedKeycardModule.currentState.stateType) {

                        case Constants.keycardSharedState.pluginReader:
                        case Constants.keycardSharedState.insertKeycard:
                        case Constants.keycardSharedState.keycardInserted:
                        case Constants.keycardSharedState.readingKeycard:
                        case Constants.keycardSharedState.biometricsPasswordFailed:
                        case Constants.keycardSharedState.biometricsPinFailed:
                        case Constants.keycardSharedState.biometricsPinInvalid:
                        case Constants.keycardSharedState.biometricsReadyToSign:
                        case Constants.keycardSharedState.notKeycard:
                        case Constants.keycardSharedState.wrongKeycard:
                            return "touch-id"
                        }
                    }
                    break
                }

                return ""
            }

            onClicked: {
                root.sharedKeycardModule.currentState.doPrimaryAction()
            }
        }
    ]
}
