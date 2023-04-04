import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Input {
    id: root

    property int maximumLength: 10
    property var locale: Qt.locale()

    readonly property alias amount: d.amount
    readonly property bool valid: validationError.length === 0
    property bool allowDecimals: true

    validationErrorTopMargin: 8
    fontPixelSize: 13
    customHeight: 36
    placeholderText: locale.zeroDigit

    textField.rightPadding: labelText.implicitWidth + labelText.anchors.rightMargin
                            + textField.leftPadding

    function setAmount(amount) {
        root.text = LocaleUtils.numberToLocaleString(amount, -1, root.locale)
    }

    QtObject {
        id: d

        property real amount: 0

        function getEffectiveDigitsCount(str) {
            const digits = LocaleUtils.getLocalizedDigitsCount(text, root.locale)
            return str.startsWith(locale.decimalPoint) ? digits + 1 : digits
        }
    }

    validator: DoubleValidator {
        id: doubleValidator

        decimals: root.allowDecimals ? 100 : 0
        bottom: 0
        notation: DoubleValidator.StandardNotation
        locale: root.locale.name
    }

    onTextChanged: {
        if (!allowDecimals)
            text = text.replace(root.locale.decimalPoint, "")

        if(text.length === 0) {
            d.amount = 0
            root.validationError = ""
            return
        }

        if (d.getEffectiveDigitsCount(text) > root.maximumLength) {
            root.validationError = qsTr("The maximum number of characters is %1").arg(root.maximumLength)
            return
        }

        let amount = LocaleUtils.numberFromLocaleString(text, root.locale)
        if (isNaN(amount)) {
            d.amount = 0
            root.validationError = qsTr("Invalid amount format")
        } else {
            d.amount = amount
            root.validationError = ""
        }
    }

    StatusBaseText {
        id: labelText

        parent: root.textField

        anchors.right: parent.right
        anchors.rightMargin: 13
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("Amount")
        color: Theme.palette.baseColor1
        font.pixelSize: 13
    }
}
