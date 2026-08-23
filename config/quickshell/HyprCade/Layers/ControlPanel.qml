import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../Data"

Scope {
    id: root

    property bool opened: false
    property bool windowVisible: false

    Palette {
        id: colors
    }

    function openPanel(): void {
        hideTimer.stop()
        root.windowVisible = true
        root.opened = true
    }

    function closePanel(): void {
        root.opened = false
        hideTimer.restart()
    }

    function togglePanel(): void {
        if (root.opened)
            root.closePanel()
            else
                root.openPanel()
    }

    Timer {
        id: hideTimer
        interval: 220

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }

    IpcHandler {
        target: "controlpanel"

        function toggle(): void {
            root.togglePanel()
        }

        function open(): void {
            root.openPanel()
        }

        function close(): void {
            root.closePanel()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.windowVisible

            anchors {
                top: true
                bottom: true
                left: true
            }

            margins {
                top: 64
                bottom: 14
                left: 0
            }

            implicitWidth: 392

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: 380

                x: root.opened ? 12 : -380

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                color: colors.background

                border.width: 1
                border.color: colors.border

                Keys.onEscapePressed: {
                    root.closePanel()
                }

                Component.onCompleted:
                forceActiveFocus()

                    ColumnLayout {
                        anchors.fill: parent

                        anchors.topMargin: 22
                        anchors.bottomMargin: 18
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18

                        spacing: 0

                        Text {
                            text: "HYPRCADE"

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 15
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        Text {
                            text: "CONTROL"

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        Text {
                            text: "SYSTEM // THEME ENGINE"

                            color: colors.muted

                            font.family: "monospace"
                            font.pixelSize: 9
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 14
                            Layout.bottomMargin: 16

                            height: 1
                            color: colors.border
                        }

                        Text {
                            text: "ACTIVE THEME"

                            color: colors.yellow

                            font.family: "monospace"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 10

                            height: 68

                            color: colors.panel

                            border.width: 1
                            border.color: colors.red

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom

                                width: 5

                                color: colors.red
                            }

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 18
                                anchors.verticalCenter: parent.verticalCenter

                                spacing: 3

                                Text {
                                    text: "> " + colors.themeName.toUpperCase()

                                    color: colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                Text {
                                    text: colors.systemName.toUpperCase()

                                    color: colors.red

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 14
                                anchors.verticalCenter: parent.verticalCenter

                                text: "ACTIVE"

                                color: colors.blue

                                font.family: "monospace"
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 18
                            Layout.bottomMargin: 16

                            height: 1
                            color: colors.border
                        }

                        // DESKTOP
                        Text {
                            text: "DESKTOP"

                            color: colors.blue

                            font.family: "monospace"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }


                        // RELOAD THEME
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 10

                            height: 42

                            color: reloadMouse.containsMouse
                            ? colors.panelAlt
                            : "transparent"

                            border.width: 1
                            border.color: reloadMouse.containsMouse
                            ? colors.yellow
                            : colors.border

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: "> RELOAD THEME"

                                color: reloadMouse.containsMouse
                                ? colors.yellow
                                : colors.text

                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: "SYNC"

                                color: colors.muted

                                font.family: "monospace"
                                font.pixelSize: 8
                            }

                            MouseArea {
                                id: reloadMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    Quickshell.execDetached([
                                        "bash",
                                        "-lc",
                                        "/home/emo/Programs/HyprCade/scripts/apply-theme.sh "
                                        + colors.themeId
                                    ])
                                }
                            }
                        }


                        // RESTART SHELL
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 6

                            height: 42

                            color: shellMouse.containsMouse
                            ? colors.panelAlt
                            : "transparent"

                            border.width: 1
                            border.color: shellMouse.containsMouse
                            ? colors.teal
                            : colors.border

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: "> RESTART SHELL"

                                color: shellMouse.containsMouse
                                ? colors.teal
                                : colors.text

                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: "QUICKSHELL"

                                color: colors.muted

                                font.family: "monospace"
                                font.pixelSize: 8
                            }

                            MouseArea {
                                id: shellMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    Quickshell.execDetached([
                                        "bash",
                                        "-lc",
                                        "pkill quickshell; "
                                        + "sleep 0.2; "
                                        + "quickshell -p "
                                        + "/home/emo/Programs/HyprCade/config/quickshell/HyprCade "
                                        + ">/tmp/hyprcade-quickshell.log 2>&1 &"
                                    ])
                                }
                            }
                        }


                        // RELOAD HYPRLAND
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 6

                            height: 42

                            color: hyprMouse.containsMouse
                            ? colors.panelAlt
                            : "transparent"

                            border.width: 1
                            border.color: hyprMouse.containsMouse
                            ? colors.red
                            : colors.border

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: "> RELOAD HYPRLAND"

                                color: hyprMouse.containsMouse
                                ? colors.red
                                : colors.text

                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: "WM"

                                color: colors.muted

                                font.family: "monospace"
                                font.pixelSize: 8
                            }

                            MouseArea {
                                id: hyprMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    Quickshell.execDetached([
                                        "hyprctl",
                                        "reload"
                                    ])
                                }
                            }
                        }


                        // DIVIDER
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 18
                            Layout.bottomMargin: 16

                            height: 1
                            color: colors.border
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.topMargin: 10

                            spacing: 7

                            Text {
                                text: "PALETTE      // LINKED"
                                color: colors.text
                                font.family: "monospace"
                                font.pixelSize: 10
                            }

                            Text {
                                text: "WALLPAPER    // LINKED"
                                color: colors.text
                                font.family: "monospace"
                                font.pixelSize: 10
                            }

                            Text {
                                text: "HYPRLAND     // LINKED"
                                color: colors.text
                                font.family: "monospace"
                                font.pixelSize: 10
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.bottomMargin: 13

                            height: 1
                            color: colors.border
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "HYPRCADE"

                                color: colors.red

                                font.family: "monospace"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "THEME // " + colors.themeId.toUpperCase()

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 9
                            }
                        }
                    }
            }
        }
    }
}
