import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
import "slotutils.js" as SlotUtils

ColumnLayout {
    width: 350
    id: confColumn
    Label {
        text: qsTr("Configure Yubico OTP for ") + SlotUtils.slotNameCapitalized(
                  selectedSlot)
        font.bold: true
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }

    Label {
        text: qsTr("When triggered, the YubiKey will output a one time password.")
        Layout.fillWidth: true
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        Layout.maximumWidth: confColumn.width
    }
    GroupBox {
        title: qsTr("Public ID")
        Layout.fillWidth: true
        Layout.maximumWidth: confColumn.width
        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: publicIdInput
                    Layout.fillWidth: true
                    enabled: !useSerialCb.checked
                    font.family: "Courier"
                    validator: RegExpValidator {
                        regExp: /[cbdefghijklnrtuv]{12}$/
                    }
                }
                CheckBox {
                    id: useSerialCb
                    enabled: device.serial
                    text: qsTr("Use encoded serial number")
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onCheckedChanged: useSerial()
                }
            }

            Label {
                text: qsTr("The Public ID can contain the following characters: cbdefghijklnrtuv.")
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.maximumWidth: confColumn.width
            }
        }
    }

    GroupBox {
        title: qsTr("Private ID")
        Layout.fillWidth: true
        Layout.maximumWidth: confColumn.width
        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: privateIdInput
                    Layout.fillWidth: true
                    font.family: "Courier"
                    validator: RegExpValidator {
                        regExp: /[0-9a-fA-F]{12}$/
                    }
                }
                Button {
                    text: qsTr("Generate")
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked: generatePrivateId()
                }
            }
            Label {
                text: qsTr("The Private ID contains 12 hexadecimal characters.")
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.maximumWidth: confColumn.width
            }
        }
    }

    GroupBox {

        title: qsTr("Secret Key")
        Layout.fillWidth: true
        Layout.maximumWidth: confColumn.width
        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: secretKeyInput
                    Layout.fillWidth: true
                    font.family: "Courier"
                    validator: RegExpValidator {
                        regExp: /[0-9a-fA-F]{32}$/
                    }
                }
                Button {
                    text: qsTr("Generate")
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    onClicked: generateKey()
                }
            }
            Label {
                text: qsTr("The Secret key contains 32 hexadecimal characters.")
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                Layout.maximumWidth: confColumn.width
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        Button {
            text: qsTr("Back")
            onClicked: stack.pop({
                                     immediate: true
                                 })
        }
        Button {
            text: qsTr("Finish")
            enabled: publicIdInput.acceptableInput
                     && privateIdInput.acceptableInput
                     && secretKeyInput.acceptableInput
            onClicked: finish()
        }
    }

    SlotOverwriteWarning {
        id: warning
        onAccepted: programOTP()
    }

    function finish() {
        if (slotsConfigured[selectedSlot - 1]) {
            warning.open()
        } else {
            programOTP()
        }
    }

    function useSerial() {
        if (useSerialCb.checked) {
            device.serial_modhex(function (res) {
                publicIdInput.text = res
            })
        }
    }

    function generatePrivateId() {
        device.random_uid(function (res) {
            privateIdInput.text = res
        })
    }

    function generateKey() {
        device.random_key(16, function (res) {
            secretKeyInput.text = res
        })
    }

    function programOTP() {
        device.program_otp(selectedSlot, publicIdInput.text,
                           privateIdInput.text, secretKeyInput.text,
                           function (error) {
                               if (!error) {
                                   confirmConfigured.open()
                               } else {
                                   if (error === 3) {
                                       writeError.open()
                                   }
                               }
                           })
    }
}
