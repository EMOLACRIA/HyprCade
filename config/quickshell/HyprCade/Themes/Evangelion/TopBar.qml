import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

import QtQuick
import QtQuick.Layouts

import "../../Data"
import "../../Components"

Scope {
    id: root

    Palette {
        id: colors
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function workspaceForId(id): var {
        const workspaces = Hyprland.workspaces.values

        for (let i = 0; i < workspaces.length; ++i) {
            if (workspaces[i].id === id)
                return workspaces[i]
        }

        return null
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: topbarWindow

            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 36
            exclusiveZone: 36

            color: "transparent"

            Rectangle {
                anchors.fill: parent

                color: "#0A0A0A"

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    height: 1
                    color: "#252525"
                }

                // ====================================================
                // LEFT SIDE
                // ====================================================

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: 15
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: 12

                    Text {
                        text: "NERV"

                        color: "#D6D6D6"

                        font.family: "monospace"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.4
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter

                        width: 1
                        height: 14

                        color: "#3A3A3A"
                    }

                    Text {
                        text: "MAGI SYSTEM"

                        color: "#747474"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.letterSpacing: 0.7
                    }

                    Text {
                        text: "●"

                        color: colors.red

                        font.pixelSize: 6
                    }
                }

                // ====================================================
                // WORKSPACES — TRUE CENTER
                // ====================================================

                Row {
                    anchors.centerIn: parent

                    spacing: 9

                    Repeater {
                        model: 6

                        Item {
                            id: workspaceItem

                            required property int index

                            property int workspaceId: index + 1

                            readonly property var workspace:
                            root.workspaceForId(workspaceId)

                            readonly property bool focused:
                            workspace !== null
                            && workspace.focused

                            readonly property bool occupied:
                            workspace !== null
                            && workspace.toplevels !== null
                            && workspace.toplevels.values.length > 0

                            width: 25
                            height: 26

                            Text {
                                anchors.centerIn: parent

                                text:
                                "0" + workspaceItem.workspaceId

                                color:
                                workspaceItem.focused
                                ? "#EAEAEA"
                                : workspaceItem.occupied
                                ? "#777777"
                                : "#3A3A3A"

                                font.family: "monospace"
                                font.pixelSize: 8
                                font.bold:
                                workspaceItem.focused
                            }

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                height:
                                workspaceItem.focused
                                ? 2
                                : 1

                                color:
                                workspaceItem.focused
                                ? colors.red
                                : "transparent"
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked: {
                                    if (
                                        workspaceItem.workspace
                                        !== null
                                    ) {
                                        workspaceItem.workspace
                                        .activate()

                                        return
                                    }

                                    if (Hyprland.usingLua) {
                                        Hyprland.dispatch(
                                            'hl.dsp.focus({ workspace = "'
                                            + workspaceItem.workspaceId
                                            + '" })'
                                        )
                                    } else {
                                        Hyprland.dispatch(
                                            "workspace "
                                            + workspaceItem.workspaceId
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // ====================================================
                // RIGHT SIDE
                // ====================================================

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: 15
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: 12

                    // TRAY
                    Row {
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 4

                        Repeater {
                            model:
                            SystemTray.items.values

                            Item {
                                id: trayItem

                                required property int index
                                required property var modelData

                                width: 18
                                height: 20

                                NervTrayMenu {
                                    id: trayMenu

                                    menu:
                                    trayItem.modelData.menu

                                    title:
                                    trayItem.modelData.title
                                    || trayItem.modelData.id
                                    || "TRAY"

                                    anchorItem:
                                    trayItem
                                }

                                Image {
                                    anchors.centerIn: parent

                                    width: 13
                                    height: 13

                                    source:
                                    trayItem.modelData.icon

                                    fillMode:
                                    Image.PreserveAspectFit

                                    smooth: true

                                    opacity:
                                    trayMouse.containsMouse
                                    ? 1.0
                                    : 0.75
                                }

                                MouseArea {
                                    id: trayMouse

                                    anchors.fill: parent

                                    acceptedButtons:
                                    Qt.LeftButton
                                    | Qt.RightButton
                                    | Qt.MiddleButton

                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked:
                                    function(mouse) {
                                        if (
                                            mouse.button
                                            === Qt.LeftButton
                                        ) {
                                            if (
                                                trayItem
                                                .modelData
                                                .onlyMenu
                                                && trayItem
                                                .modelData
                                                .hasMenu
                                            ) {
                                                trayMenu
                                                .openMenu()
                                            } else {
                                                trayItem
                                                .modelData
                                                .activate()
                                            }

                                            return
                                        }

                                        if (
                                            mouse.button
                                            === Qt.RightButton
                                        ) {
                                            if (
                                                trayItem
                                                .modelData
                                                .hasMenu
                                            ) {
                                                trayMenu
                                                .openMenu()
                                            }

                                            return
                                        }

                                        if (
                                            mouse.button
                                            === Qt.MiddleButton
                                        ) {
                                            trayItem
                                            .modelData
                                            .secondaryActivate()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter

                        width: 1
                        height: 14

                        color: "#323232"
                    }

                    // NETWORK
                    Item {
                        id: networkBlock

                        width: 38
                        height: 20

                        readonly property var devices:
                        Networking.devices
                        ? Networking.devices.values
                        : []

                        readonly property var activeDevice: {
                            for (
                                let i = 0;
                            i < devices.length;
                            ++i
                            ) {
                                if (devices[i].connected)
                                    return devices[i]
                            }

                            return null
                        }

                        readonly property bool online:
                        activeDevice !== null

                        Text {
                            anchors.centerIn: parent

                            text:
                            networkBlock.online
                            ? "NET"
                            : "OFF"

                            color:
                            networkBlock.online
                            ? "#8B8B8B"
                            : colors.red

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                            Qt.PointingHandCursor

                            onClicked: {
                                Quickshell.execDetached([
                                    "nm-connection-editor"
                                ])
                            }
                        }
                    }

                    // BATTERY
                    Item {
                        id: batteryBlock

                        width: 47
                        height: 20

                        property real batteryLevel:
                        UPower.displayDevice.ready
                        ? UPower.displayDevice.percentage
                        * 100
                        : -1

                        Text {
                            anchors.centerIn: parent

                            text:
                            batteryBlock.batteryLevel >= 0
                            ? Math.round(
                                batteryBlock.batteryLevel
                            ) + "%"
                            : "--"

                            color:
                            batteryBlock.batteryLevel <= 20
                            ? colors.red
                            : "#8B8B8B"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                            Qt.PointingHandCursor

                            onClicked: {
                                Quickshell.execDetached([
                                    "qs",
                                    "-p",
                                    "/home/emo/Programs/HyprCade/config/quickshell/HyprCade",
                                    "ipc",
                                    "call",
                                    "rightpanel",
                                    "toggle"
                                ])
                            }
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter

                        width: 1
                        height: 14

                        color: "#323232"
                    }

                    // CLOCK
                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text:
                        Qt.formatDateTime(
                            clock.date,
                            "HH:mm"
                        )

                        color: "#D6D6D6"

                        font.family: "monospace"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 0.6
                    }
                }
            }
        }
    }
}
