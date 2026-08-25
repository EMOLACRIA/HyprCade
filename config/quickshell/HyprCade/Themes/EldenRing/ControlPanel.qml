import Quickshell
import Quickshell.Io

import QtQuick
import QtQuick.Layouts

import "../../Data"

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
        interval: 240

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
            id: window

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
                bottom: 18
                left: 0
            }

            implicitWidth: 404

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            Rectangle {
                id: panel

                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: 392

                x:
                    root.opened
                    ? 12
                    : -392

                Behavior on x {
                    NumberAnimation {
                        duration: 260
                        easing.type:
                            Easing.OutCubic
                    }
                }

                color: colors.background

                border.width: 1
                border.color: colors.border

                Keys.onEscapePressed:
                    root.closePanel()

                Component.onCompleted:
                    forceActiveFocus()

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5

                    color: "transparent"

                    border.width: 1
                    border.color: colors.panelAlt

                    opacity: 0.75
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    width: 96
                    height: 1

                    color: colors.yellow
                    opacity: 0.6
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 24
                        bottomMargin: 20
                        leftMargin: 22
                        rightMargin: 22
                    }

                    spacing: 0

                    // ====================================================
                    // HEADER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 1

                            Text {
                                text: "GRACE"

                                color: colors.yellow

                                font.family: "serif"
                                font.pixelSize: 16
                                font.bold: true
                                font.letterSpacing: 1.5
                            }

                            Text {
                                text: "CONFIGURATION"

                                color: colors.text

                                font.family: "serif"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                text:
                                    "HYPRCADE  //  WORLD STATE"

                                color: colors.muted

                                font.family: "serif"
                                font.pixelSize: 8
                                font.letterSpacing: 0.7
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Column {
                            spacing: 0

                            Text {
                                anchors.right:
                                    parent.right

                                text: "✦"

                                color: colors.yellow

                                font.family: "serif"
                                font.pixelSize: 20
                            }

                            Text {
                                anchors.right:
                                    parent.right

                                text: "BOUND"

                                color: colors.blue

                                font.family: "serif"
                                font.pixelSize: 7
                                font.bold: true
                                font.letterSpacing: 0.7
                            }
                        }
                    }

                    Text {
                        Layout.topMargin: 10

                        text:
                            "Shape the world, then let Grace restore it."

                        color: colors.text

                        font.family: "serif"
                        font.pixelSize: 9
                        font.italic: true
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        Layout.topMargin: 15
                        Layout.bottomMargin: 14

                        height: 1
                        color: colors.border
                    }

                    // ====================================================
                    // CURRENT WORLD
                    // ====================================================

                    Text {
                        text: "CURRENT WORLD"

                        color: colors.yellow

                        font.family: "serif"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        height: 74

                        color: colors.panel

                        border.width: 1
                        border.color: colors.yellow

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            width: 3
                            color: colors.yellow
                        }

                        Column {
                            anchors {
                                left: parent.left
                                leftMargin: 17
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            spacing: 3

                            Text {
                                text:
                                    colors.themeName.toUpperCase()

                                color: colors.text

                                font.family: "serif"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 0.7
                            }

                            Text {
                                text:
                                    colors.systemName.toUpperCase()

                                color: colors.yellow

                                font.family: "serif"
                                font.pixelSize: 8
                                font.letterSpacing: 0.8
                            }
                        }

                        Column {
                            anchors {
                                right: parent.right
                                rightMargin: 14
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            spacing: 2

                            Text {
                                anchors.right:
                                    parent.right

                                text: "ACTIVE"

                                color: colors.blue

                                font.family: "serif"
                                font.pixelSize: 8
                                font.bold: true
                            }

                            Text {
                                anchors.right:
                                    parent.right

                                text: "GUIDED"

                                color: colors.muted

                                font.family: "serif"
                                font.pixelSize: 7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        Layout.topMargin: 16
                        Layout.bottomMargin: 14

                        height: 1
                        color: colors.border
                    }

                    // ====================================================
                    // WORLD COMMANDS
                    // ====================================================

                    Text {
                        text: "WORLD COMMANDS"

                        color: colors.blue

                        font.family: "serif"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        Layout.topMargin: 2

                        text:
                            "Restore bindings and active state."

                        color: colors.muted

                        font.family: "serif"
                        font.pixelSize: 7
                        font.italic: true
                    }

                    ActionRow {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        title: "RESTORE GRACE"
                        subtitle: "RELOAD THEME"

                        accent: colors.yellow

                        onTriggered: {
                            Quickshell.execDetached([
                                "bash",
                                "-lc",
                                "/home/emo/Programs/HyprCade/scripts/apply-theme.sh "
                                + colors.themeId
                            ])
                        }
                    }

                    ActionRow {
                        Layout.fillWidth: true
                        Layout.topMargin: 6

                        title: "REAWAKEN THE SHELL"
                        subtitle: "QUICKSHELL"

                        accent: colors.blue

                        onTriggered: {
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

                    ActionRow {
                        Layout.fillWidth: true
                        Layout.topMargin: 6

                        title: "RECAST THE WORLD"
                        subtitle: "HYPRLAND"

                        accent: colors.red

                        onTriggered: {
                            Quickshell.execDetached([
                                "hyprctl",
                                "reload"
                            ])
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        Layout.topMargin: 17
                        Layout.bottomMargin: 14

                        height: 1
                        color: colors.border
                    }

                    // ====================================================
                    // BINDINGS
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "BINDINGS"

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "3 / 3"

                            color: colors.muted

                            font.family: "serif"
                            font.pixelSize: 7
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        spacing: 7

                        BindingRow {
                            Layout.fillWidth: true

                            label: "PALETTE"
                            stateText: "BOUND"
                            accent: colors.yellow
                        }

                        BindingRow {
                            Layout.fillWidth: true

                            label: "WALLPAPER"
                            stateText: "BOUND"
                            accent: colors.blue
                        }

                        BindingRow {
                            Layout.fillWidth: true

                            label: "HYPRLAND"
                            stateText: "BOUND"
                            accent: colors.text
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 11

                        height: 1
                        color: colors.border
                    }

                    // ====================================================
                    // FOOTER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                                "THE WORLD REMEMBERS."

                            color: colors.muted

                            font.family: "serif"
                            font.pixelSize: 7
                            font.italic: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                                "✦  "
                                + colors.themeId.toUpperCase()

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.5
                        }
                    }
                }
            }
        }
    }

    component ActionRow: Rectangle {
        id: actionRoot

        property string title: ""
        property string subtitle: ""
        property color accent: colors.yellow

        signal triggered()

        height: 46

        color:
            actionMouse.containsMouse
            ? colors.panelAlt
            : "transparent"

        border.width: 1

        border.color:
            actionMouse.containsMouse
            ? actionRoot.accent
            : colors.border

        Text {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter:
                    parent.verticalCenter
            }

            text:
                actionMouse.containsMouse
                ? "✦  " + actionRoot.title
                : "·  " + actionRoot.title

            color:
                actionMouse.containsMouse
                ? actionRoot.accent
                : colors.text

            font.family: "serif"
            font.pixelSize: 10
            font.bold:
                actionMouse.containsMouse
            font.letterSpacing: 0.5
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter:
                    parent.verticalCenter
            }

            text: actionRoot.subtitle

            color: colors.muted

            font.family: "serif"
            font.pixelSize: 7
            font.letterSpacing: 0.5
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                actionRoot.triggered()
        }
    }

    component BindingRow: Rectangle {
        property string label: ""
        property string stateText: ""
        property color accent: colors.text

        height: 30

        color: colors.panel

        border.width: 1
        border.color: colors.border

        Text {
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter:
                    parent.verticalCenter
            }

            text: parent.label

            color: colors.text

            font.family: "serif"
            font.pixelSize: 8
            font.letterSpacing: 0.5
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter:
                    parent.verticalCenter
            }

            text: parent.stateText

            color: parent.accent

            font.family: "serif"
            font.pixelSize: 7
            font.bold: true
            font.letterSpacing: 0.5
        }
    }
}
