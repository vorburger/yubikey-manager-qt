import QtQuick 2.5
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.3

ColumnLayout {
    id: otpView
    Component.onCompleted: load()
    property bool isBusy

    function load() {
        isBusy = true
        yubiKey.slots_status(function (res) {
            views.slot1Configured = res[0]
            views.slot2Configured = res[1]
            views.selectedSlot = 0
            isBusy = false
        })
    }

    readonly property string slotIsConfigured: qsTr("The slot is configured.")
    readonly property string slotIsEmpty: qsTr("The slot is empty.")

    function slot1StatusTxt() {
        return slot1Configured ? slotIsConfigured : slotIsEmpty
    }

    function slot2StatusTxt() {
        return slot2Configured ? slotIsConfigured : slotIsEmpty
    }

    function deleteSelectedSlot() {
        yubiKey.erase_slot(views.selectedSlot, function (resp) {
            if (resp.success) {
                views.otpDeleteSuccess()
            } else {
                if (resp.error === 'write error') {
                    views.otpWriteError()
                } else {
                    views.otpGeneralError(resp.error)
                }
            }
        })
    }

    function swapConfigurations() {
        yubiKey.swap_slots(function (resp) {
            if (resp.success) {
                views.otpSwapConfigurationsSuccess()
            } else {
                if (resp.error === 'write error') {
                    views.otpWriteError()
                } else {
                    views.otpGeneralError(resp.error)
                }
            }
        })
    }

    BusyIndicator {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        running: isBusy
        visible: running
    }

    OtpSwapConfigurationsPopup {
        id: otpSwapConfigurationsPopup
        onAccepted: swapConfigurations()
    }

    OtpDeleteSlotPopup {
        id: otpDeleteSlotPopup
        onAccepted: deleteSelectedSlot()
    }

    ColumnLayout {
        visible: !isBusy
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 20
        Layout.preferredHeight: app.height

        Heading1 {
            text: qsTr("OTP")
        }
        BreadCrumbRow {
            BreadCrumb {
                text: qsTr("Home")
                action: views.home
            }

            BreadCrumbSeparator {
            }
            BreadCrumb {
                text: qsTr("OTP")
                active: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            ColumnLayout {
                Label {
                    text: qsTr("Short Touch (Slot 1)")
                    font.pointSize: constants.h2
                    color: slot1Configured ? yubicoBlue : yubicoGrey
                }
                Label {
                    text: slot1StatusTxt()
                    font.pointSize: 14
                    color: slot1Configured ? yubicoBlue : yubicoGrey
                }
                RowLayout {
                    Button {
                        text: qsTr("Delete")
                        enabled: views.slot1Configured
                        onClicked: {
                            views.selectSlot1()
                            otpDeleteSlotPopup.open()
                        }
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Permanently delete the configuration of Short Touch (Slot 1).")
                    }
                    Button {
                        text: qsTr("Configure")
                        highlighted: true
                        onClicked: {
                            views.selectSlot1()
                            views.push(otpConfigureSlotView)
                        }
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Configure a credential in Short Touch (Slot 1).")
                    }
                }
            }
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Button {
                    text: qsTr("Swap ⇄")
                    font.family: "Helvetica Neue"
                    Material.foreground: yubicoBlue
                    font.capitalization: Font.MixedCase
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    onClicked: otpSwapConfigurationsPopup.open()
                    flat: true
                    ToolTip.delay: 1000
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Swap the configurations between the two slots.")
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Label {
                    id: slot2Heading
                    text: qsTr("Long Touch (Slot 2)")
                    font.pointSize: constants.h2
                    color: views.slot2Configured ? yubicoBlue : yubicoGrey
                }
                Label {
                    text: slot2StatusTxt()
                    font.pointSize: 14
                    color: slot1Configured ? yubicoBlue : yubicoGrey
                }
                RowLayout {
                    Button {
                        text: qsTr("Delete")
                        enabled: views.slot2Configured
                        onClicked: {
                            views.selectSlot2()
                            otpDeleteSlotPopup.open()
                        }
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Permanently delete the configuration of Long Touch (Slot 2).")
                    }
                    Button {
                        text: qsTr("Configure")
                        highlighted: true
                        onClicked: {
                            views.selectSlot2()
                            views.push(otpConfigureSlotView)
                        }
                        ToolTip.delay: 1000
                        ToolTip.visible: hovered
                        ToolTip.text: qsTr("Configure a credential in Long Touch (Slot 2).")
                    }
                }
            }
        }
    }
}