import Quickshell
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

                                width: 34
                                height: 30

                                color: index === 0
                                ? colors.red
                                : "transparent"

                                border.width: 1
                                border.color: index === 0
                                ? colors.red
                                : colors.border

                                Text {
                                    anchors.centerIn: parent

                                    text: String(index + 1).padStart(2, "0")

                                    color: index === 0
                                    ? colors.background
                                    : colors.blue

                                    font.family: "monospace"
                                    font.pixelSize: 11
                                    font.bold: true
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
                            spacing: 0

                            Text {
                                text: "NET"
                                color: colors.blue

                                font.family: "monospace"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Text {
                                text: "ONLINE"
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
                            spacing: 0

                            Text {
                                text: "BAT"
                                color: colors.yellow

                                font.family: "monospace"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Text {
                                text: "78%"
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
