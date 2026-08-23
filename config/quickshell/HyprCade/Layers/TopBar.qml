import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.UPower

import QtQuick
import QtQuick.Layouts


import "../Data"

Scope {
    id: root

    Palette {
        id: colors
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 52
            exclusiveZone: 52
            color: "transparent"

            Rectangle {
                anchors.fill: parent

                color: colors.background

                border.width: 1
                border.color: colors.border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 22
                    anchors.rightMargin: 22

                    spacing: 18

                    // ─────────────────────
                    // HYPRCADE / BEBOP
                    // ─────────────────────

                    Column {
                        Layout.alignment: Qt.AlignVCenter

                        spacing: -2

                        Text {
                            text: "HYPRCADE"

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 16
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        Text {
                            text: "BEBOP SYSTEM // 01"

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1
                        }
                    }

                    Rectangle {
                        Layout.leftMargin: 10

                        width: 1
                        height: 28

                        color: colors.border
                    }

                    // ─────────────────────
                    // BOUNTY
                    // ─────────────────────

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter

                        implicitWidth: 162
                        implicitHeight: 30

                        color: "transparent"

                        border.width: 1
                        border.color: colors.red

                        Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: "BOUNTY"
                                color: colors.red

                                font.family: "monospace"
                                font.bold: true
                                font.pixelSize: 11
                            }

                            Text {
                                text: "$ 4,250,000"
                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 11
                            }
                        }
                    }

                    // Push workspaces toward center
                    Item {
                        Layout.fillWidth: true
                    }

                    // ─────────────────────
                    // WORKSPACES
                    // placeholder for now
                    // ─────────────────────

                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 7

                        Repeater {
                            model: 6

                            Rectangle {
                                required property int index

                                property int workspaceId: index + 1
                                property bool focused:
                                Hyprland.focusedWorkspace !== null
                                && Hyprland.focusedWorkspace.id === workspaceId

                                width: 34
                                height: 30

                                color: focused
                                ? colors.red
                                : "transparent"

                                border.width: 1
                                border.color: focused
                                ? colors.red
                                : colors.border

                                Text {
                                    anchors.centerIn: parent

                                    text: String(workspaceId).padStart(2, "0")

                                    color: focused
                                    ? colors.background
                                    : colors.blue

                                    font.family: "monospace"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        if (Hyprland.usingLua) {
                                            Hyprland.dispatch(
                                                'hl.dsp.focus({ workspace = "' + workspaceId + '" })'
                                            )
                                        } else {
                                            Hyprland.dispatch(
                                                "workspace " + workspaceId
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // ─────────────────────
                    // STATUS
                    // ─────────────────────

                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 22

                        Column {
                            id: networkBlock

                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            readonly property var devices:
                            Networking.devices
                            ? Networking.devices.values
                            : []

                            readonly property bool online: {
                                for (let i = 0; i < devices.length; ++i) {
                                    if (devices[i].connected)
                                        return true
                                }

                                return false
                            }

                            Text {
                                text: "NET"

                                color: networkBlock.online
                                ? colors.blue
                                : colors.red

                                font.family: "monospace"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Text {
                                text: networkBlock.online
                                ? "ONLINE"
                                : "OFFLINE"

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 9
                            }
                        }

                        Rectangle {
                            width: 1
                            height: 28
                            color: colors.border
                        }

                        Column {
                            id: batteryBlock

                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            // Quickshell returns battery charge as 0.0 - 1.0.
                            property real batteryLevel:
                            UPower.displayDevice.ready
                            ? UPower.displayDevice.percentage * 100
                            : -1

                            Row {
                                spacing: 8

                                Text {
                                    text: "BAT"

                                    color: batteryBlock.batteryLevel >= 0
                                    && batteryBlock.batteryLevel <= 20
                                    ? colors.red
                                    : colors.yellow

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                Text {
                                    text: batteryBlock.batteryLevel >= 0
                                    ? Math.round(batteryBlock.batteryLevel) + "%"
                                    : "--%"

                                    color: colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                }
                            }

                            Row {
                                spacing: 2

                                Repeater {
                                    model: 8

                                    Rectangle {
                                        required property int index

                                        width: 5
                                        height: 4

                                        property int activeSegments:
                                        batteryBlock.batteryLevel >= 0
                                        ? Math.ceil(batteryBlock.batteryLevel / 12.5)
                                        : 0

                                        color: index < activeSegments
                                        ? (
                                            batteryBlock.batteryLevel <= 20
                                            ? colors.red
                                            : colors.yellow
                                        )
                                        : colors.border
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 1
                            height: 28
                            color: colors.border
                        }

                        Text {
                            text: Qt.formatDateTime(
                                clock.date,
                                "HH:mm"
                            )

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 19
                            font.bold: true
                            font.letterSpacing: 1
                        }
                    }
                }
            }
        }
    }
}
