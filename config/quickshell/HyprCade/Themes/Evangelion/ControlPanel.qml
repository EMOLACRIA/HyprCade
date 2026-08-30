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

        interval: 180

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
                top: 48
                bottom: 18
                left: 0
            }

            implicitWidth: 366

            exclusiveZone: 0
            color: "transparent"
            focusable: true

            onVisibleChanged: {
                if (visible)
                    controlSurface.forceActiveFocus()
            }

            Rectangle {
                id: controlSurface

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                width: 350

                x:
                root.opened
                ? 10
                : -352

                focus: true

                Keys.onEscapePressed: {
                    root.closePanel()
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 170
                        easing.type: Easing.OutCubic
                    }
                }

                color: "#0A0A0A"

                border.width: 1
                border.color: "#262626"

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: 2
                    color: colors.red
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 19
                        bottomMargin: 16
                        leftMargin: 19
                        rightMargin: 18
                    }

                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: -2

                            Text {
                                text: "NERV CONTROL"

                                color: "#D8D8D8"

                                font.family: "monospace"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                text: "MAGI SYSTEM INTERFACE"

                                color: "#5D5D5D"

                                font.family: "monospace"
                                font.pixelSize: 7
                                font.letterSpacing: 0.6
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Column {
                            spacing: -2

                            Text {
                                anchors.right: parent.right

                                text: "AUTH // 01"

                                color: "#555555"

                                font.family: "monospace"
                                font.pixelSize: 7
                            }

                            Text {
                                anchors.right: parent.right

                                text: "ONLINE"

                                color: "#777777"

                                font.family: "monospace"
                                font.pixelSize: 7
                                font.bold: true
                            }
                        }
                    }

                    Divider {
                        Layout.topMargin: 13
                        Layout.bottomMargin: 14
                    }

                    Text {
                        text: "ACTIVE CONFIGURATION"

                        color: "#5F5F5F"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        height: 66

                        color: "#0D0D0D"

                        border.width: 1
                        border.color: "#292929"

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            width: 3
                            color: colors.red
                        }

                        Column {
                            anchors {
                                left: parent.left
                                leftMargin: 14
                                verticalCenter:
                                parent.verticalCenter
                            }

                            spacing: 2

                            Text {
                                text:
                                colors.themeName
                                .toUpperCase()

                                color: "#CCCCCC"

                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            Text {
                                text:
                                colors.systemName
                                .toUpperCase()

                                color: "#565656"

                                font.family: "monospace"
                                font.pixelSize: 7
                            }
                        }

                        Text {
                            anchors {
                                right: parent.right
                                rightMargin: 12
                                verticalCenter:
                                parent.verticalCenter
                            }

                            text: "ACTIVE"

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                        }
                    }

                    Divider {
                        Layout.topMargin: 14
                        Layout.bottomMargin: 14
                    }

                    Text {
                        text: "MAGI AUTHORITY"

                        color: "#5F5F5F"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        spacing: 5

                        MagiNode {
                            Layout.fillWidth: true

                            number: "01"
                            name: "MELCHIOR"
                        }

                        MagiNode {
                            Layout.fillWidth: true

                            number: "02"
                            name: "BALTHASAR"
                        }

                        MagiNode {
                            Layout.fillWidth: true

                            number: "03"
                            name: "CASPER"
                        }
                    }

                    Divider {
                        Layout.topMargin: 14
                        Layout.bottomMargin: 14
                    }

                    Text {
                        text: "SYSTEM OPERATIONS"

                        color: "#5F5F5F"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        spacing: 6

                        OperationButton {
                            Layout.fillWidth: true

                            number: "01"
                            title: "RELOAD THEME"
                            subtitle: "SYNC ACTIVE CONFIGURATION"

                            onActivated: {
                                Quickshell.execDetached([
                                    "bash",
                                    "-lc",
                                    "/home/emo/Programs/HyprCade/scripts/apply-theme.sh "
                                    + colors.themeId
                                ])
                            }
                        }

                        OperationButton {
                            Layout.fillWidth: true

                            number: "02"
                            title: "RESTART SHELL"
                            subtitle: "REINITIALIZE QUICKSHELL"

                            onActivated: {
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

                        OperationButton {
                            Layout.fillWidth: true

                            number: "03"
                            title: "RELOAD HYPRLAND"
                            subtitle: "RELOAD WINDOW MANAGER"

                            onActivated: {
                                Quickshell.execDetached([
                                    "hyprctl",
                                    "reload"
                                ])
                            }
                        }
                    }

                    Divider {
                        Layout.topMargin: 15
                        Layout.bottomMargin: 13
                    }

                    Text {
                        text: "SYSTEM LINKS"

                        color: "#5F5F5F"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        spacing: 8

                        LinkRow {
                            Layout.fillWidth: true

                            label: "PALETTE"
                        }

                        LinkRow {
                            Layout.fillWidth: true

                            label: "WALLPAPER"
                        }

                        LinkRow {
                            Layout.fillWidth: true

                            label: "HYPRLAND"
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Divider {
                        Layout.bottomMargin: 11
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "NERV"

                            color: "#666666"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.7
                        }

                        Text {
                            text: "//"

                            color: "#343434"

                            font.family: "monospace"
                            font.pixelSize: 7
                        }

                        Text {
                            text: "MAGI CONTROL"

                            color: "#4F4F4F"

                            font.family: "monospace"
                            font.pixelSize: 7
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "ESC CLOSE"

                            color: "#444444"

                            font.family: "monospace"
                            font.pixelSize: 6
                        }
                    }
                }
            }
        }
    }

    component Divider: Rectangle {
        Layout.fillWidth: true

        implicitHeight: 1
        color: "#242424"
    }

    component MagiNode: Rectangle {
        required property string number
        required property string name

        implicitHeight: 50

        color: "#0D0D0D"

        border.width: 1
        border.color: "#252525"

        Column {
            anchors.centerIn: parent

            spacing: 1

            Text {
                anchors.horizontalCenter:
                parent.horizontalCenter

                text: number

                color: colors.red

                font.family: "monospace"
                font.pixelSize: 6
                font.bold: true
            }

            Text {
                anchors.horizontalCenter:
                parent.horizontalCenter

                text: name

                color: "#777777"

                font.family: "monospace"
                font.pixelSize: 6
                font.bold: true
            }

            Text {
                anchors.horizontalCenter:
                parent.horizontalCenter

                text: "NOMINAL"

                color: "#414141"

                font.family: "monospace"
                font.pixelSize: 5
            }
        }
    }

    component OperationButton: Rectangle {
        required property string number
        required property string title
        required property string subtitle

        signal activated()

        implicitHeight: 49

        color:
        operationMouse.containsMouse
        ? "#111111"
        : "transparent"

        border.width: 1

        border.color:
        operationMouse.containsMouse
        ? "#343434"
        : "#232323"

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            width:
            operationMouse.containsMouse
            ? 3
            : 1

            color:
            operationMouse.containsMouse
            ? colors.red
            : "#262626"
        }

        Text {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter:
                parent.verticalCenter
            }

            text: number

            color:
            operationMouse.containsMouse
            ? colors.red
            : "#444444"

            font.family: "monospace"
            font.pixelSize: 6
            font.bold: true
        }

        Column {
            anchors {
                left: parent.left
                leftMargin: 42
                verticalCenter:
                parent.verticalCenter
            }

            spacing: 2

            Text {
                text: title

                color:
                operationMouse.containsMouse
                ? "#DADADA"
                : "#999999"

                font.family: "monospace"
                font.pixelSize: 8
                font.bold: true
            }

            Text {
                text: subtitle

                color: "#494949"

                font.family: "monospace"
                font.pixelSize: 6
            }
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 11
                verticalCenter:
                parent.verticalCenter
            }

            text:
            operationMouse.containsMouse
            ? ">"
            : ""

            color: colors.red

            font.family: "monospace"
            font.pixelSize: 9
            font.bold: true
        }

        MouseArea {
            id: operationMouse

            anchors.fill: parent
            hoverEnabled: true

            cursorShape:
            Qt.PointingHandCursor

            onClicked:
            parent.activated()
        }
    }

    component LinkRow: RowLayout {
        required property string label

        Text {
            text: label

            color: "#666666"

            font.family: "monospace"
            font.pixelSize: 7
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: "LINKED"

            color: "#555555"

            font.family: "monospace"
            font.pixelSize: 6
        }

        Text {
            text: "●"

            color: colors.red
            font.pixelSize: 5
        }
    }
}
