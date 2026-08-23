import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../Data"

Scope {
    id: root

    property bool opened: false

    Palette {
        id: colors
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.opened = !root.opened
        }

        function open(): void {
            root.opened = true
        }

        function close(): void {
            root.opened = false
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.opened

            anchors {
                top: true
                bottom: true
                left: true
            }

            margins {
                top: 64
                bottom: 14
                left: 12
            }

            implicitWidth: 300

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            Rectangle {
                anchors.fill: parent

                color: colors.background

                border.width: 1
                border.color: colors.border

                ColumnLayout {
                    anchors.fill: parent

                    anchors.topMargin: 22
                    anchors.bottomMargin: 18
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    spacing: 0

                    // ──────────────────────────
                    // HEADER
                    // ──────────────────────────

                    Text {
                        text: "SYSTEM"

                        color: colors.yellow

                        font.family: "monospace"
                        font.pixelSize: 15
                        font.bold: true
                        font.letterSpacing: 1.2
                    }

                    Text {
                        text: "MENU"

                        color: colors.text

                        font.family: "monospace"
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: "システム"

                        color: colors.muted

                        font.pixelSize: 9
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 14
                        Layout.bottomMargin: 12

                        height: 1

                        color: colors.border
                    }

                    // ──────────────────────────
                    // MENU
                    // ──────────────────────────

                    ListView {
                        id: menuList

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 3

                        clip: true

                        model: [
                            {
                                label: "TERMINAL",
                                sub: "ターミナル",
                                accent: colors.blue,
                                command: "kitty",
                                enabled: true
                            },
                            {
                                label: "FILES",
                                sub: "ファイル",
                                accent: colors.yellow,
                                command: "dolphin",
                                enabled: true
                            },
                            {
                                label: "BROWSER",
                                sub: "ブラウザ",
                                accent: colors.red,
                                command: "zen-browser",
                                enabled: true
                            },
                            {
                                label: "MUSIC",
                                sub: "ミュージック",
                                accent: colors.blue,
                                command:
                                "command -v spotify >/dev/null && spotify || "
                                + "command -v spotify-launcher >/dev/null && spotify-launcher",
                                enabled: true
                            },
                            {
                                label: "LOCK",
                                sub: "ロック",
                                accent: colors.yellow,
                                command: "hyprlock",
                                enabled: true
                            },
                            {
                                label: "HYPRCADE",
                                sub: "CONTROL // SOON",
                                accent: colors.teal,
                                command: "",
                                enabled: false
                            }
                        ]

                        delegate: Rectangle {
                            id: menuEntry

                            required property var modelData

                            width: menuList.width
                            height: 58

                            color: mouse.containsMouse
                            ? colors.panelAlt
                            : "transparent"

                            border.width: 1

                            border.color: mouse.containsMouse
                            ? modelData.accent
                            : "transparent"

                            opacity: modelData.enabled ? 1.0 : 0.45

                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter

                                width: 4
                                height: 32

                                color: modelData.accent
                            }

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 17
                                anchors.verticalCenter: parent.verticalCenter

                                spacing: 2

                                Text {
                                    text: "> " + modelData.label

                                    color: mouse.containsMouse
                                    ? modelData.accent
                                    : colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.letterSpacing: 0.5
                                }

                                Text {
                                    text: modelData.sub

                                    color: colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                }
                            }

                            MouseArea {
                                id: mouse

                                anchors.fill: parent

                                hoverEnabled: true
                                enabled: modelData.enabled

                                cursorShape: modelData.enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                                onClicked: {
                                    Quickshell.execDetached([
                                        "sh",
                                        "-lc",
                                        modelData.command
                                    ])

                                    root.opened = false
                                }
                            }
                        }
                    }

                    // ──────────────────────────
                    // FOOTER
                    // ──────────────────────────

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 13

                        height: 1
                        color: colors.border
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "BEBOP SYS."

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "STAY COOL"

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.letterSpacing: 1
                        }
                    }
                }
            }
        }
    }
}
