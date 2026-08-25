
import Quickshell
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

import QtQuick
import QtQuick.Layouts
import "../Data"
import "../Components"

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

            property bool calendarOpen: false

            property date calendarMonth: new Date(
                clock.date.getFullYear(),
                                                  clock.date.getMonth(),
                                                  1
            )

            readonly property int calendarOffset:
            (calendarMonth.getDay() + 6) % 7

            readonly property int calendarDays: new Date(
                calendarMonth.getFullYear(),
                                                         calendarMonth.getMonth() + 1,
                                                         0
            ).getDate()

            function shiftCalendarMonth(delta): void {
                calendarMonth = new Date(
                    calendarMonth.getFullYear(),
                                         calendarMonth.getMonth() + delta,
                                         1
                )
            }

            function resetCalendarMonth(): void {
                calendarMonth = new Date(
                    clock.date.getFullYear(),
                                         clock.date.getMonth(),
                                         1
                )
            }

            function calendarTitle(): string {
                const months = [
                    "JANUARY", "FEBRUARY", "MARCH",
                    "APRIL", "MAY", "JUNE",
                    "JULY", "AUGUST", "SEPTEMBER",
                    "OCTOBER", "NOVEMBER", "DECEMBER"
                ]

                return months[calendarMonth.getMonth()]
                + " // "
                + calendarMonth.getFullYear()
            }

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 44
            exclusiveZone: 44

            color: "transparent"

            Rectangle {
                anchors.fill: parent

                color: colors.background

                border.width: 1
                border.color: colors.border

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    spacing: 12

                    // ─────────────────────
                    // HYPRCADE / THEME
                    // ─────────────────────

                    Column {
                        Layout.alignment: Qt.AlignVCenter

                        spacing: -2

                        Text {
                            text: "HYPRCADE"

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 14
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        Text {
                            text: colors.systemName.toUpperCase() + " // 01"

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.bold: true
                            font.letterSpacing: 1
                        }
                    }

                    Rectangle {
                        Layout.leftMargin: 6

                        width: 1
                        height: 26

                        color: colors.border
                    }

                    // ─────────────────────
                    // BOUNTY
                    // ─────────────────────

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter

                        implicitWidth: 150
                        implicitHeight: 26

                        color: "transparent"

                        border.width: 1
                        border.color: colors.red

                        Row {
                            anchors.centerIn: parent

                            spacing: 9

                            Text {
                                text: "BOUNTY"

                                color: colors.red

                                font.family: "monospace"
                                font.bold: true
                                font.pixelSize: 9
                            }

                            Text {
                                text: "$ 4,250,000"

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 9
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // ─────────────────────
                    // WORKSPACES
                    // ─────────────────────

                    Row {
                        Layout.alignment: Qt.AlignVCenter

                        spacing: 6

                        Repeater {
                            model: 6

                            Rectangle {
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

                                readonly property bool urgent:
                                workspace !== null
                                && workspace.urgent

                                width: 30
                                height: 24

                                color:
                                focused
                                ? colors.red
                                : "transparent"

                                border.width: 1

                                border.color:
                                focused
                                ? colors.red
                                : urgent
                                ? colors.yellow
                                : occupied
                                ? colors.blue
                                : colors.border

                                opacity:
                                focused || occupied || urgent
                                ? 1.0
                                : 0.45

                                Text {
                                    anchors.centerIn: parent

                                    text:
                                    String(parent.workspaceId)
                                    .padStart(2, "0")

                                    color:
                                    parent.focused
                                    ? colors.background
                                    : parent.urgent
                                    ? colors.yellow
                                    : parent.occupied
                                    ? colors.blue
                                    : colors.muted

                                    font.family: "monospace"
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        if (parent.workspace !== null) {
                                            parent.workspace.activate()
                                            return
                                        }

                                        if (Hyprland.usingLua) {
                                            Hyprland.dispatch(
                                                'hl.dsp.focus({ workspace = "'
                                                + parent.workspaceId
                                                + '" })'
                                            )
                                        } else {
                                            Hyprland.dispatch(
                                                "workspace "
                                                + parent.workspaceId
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
                    // SYSTEM TRAY
                    // ─────────────────────

                    Rectangle {
                        visible:
                        SystemTray.items.values.length > 0

                        width: 1
                        height: 26

                        color: colors.border
                    }

                    Row {
                        visible:
                        SystemTray.items.values.length > 0

                        Layout.alignment: Qt.AlignVCenter

                        spacing: 5

                        Repeater {
                            model: SystemTray.items.values

                            Rectangle {
                                id: trayItem

                                required property int index
                                required property var modelData

                                width: 24
                                height: 24

                                color:
                                trayMouse.containsMouse
                                ? colors.panelAlt
                                : "transparent"

                                border.width:
                                trayMouse.containsMouse
                                ? 1
                                : 0

                                border.color: colors.blue


                                // ─────────────────────────────
                                // PLATFORM MENU
                                // ─────────────────────────────


                                TrayMenu {
                                    id: trayMenu

                                    menu: trayItem.modelData.menu

                                    title:
                                    trayItem.modelData.title
                                    || trayItem.modelData.id
                                    || "TRAY"

                                    anchorItem: trayItem
                                }




                                // ─────────────────────────────
                                // ICON
                                // ─────────────────────────────

                                Image {
                                    anchors.centerIn: parent

                                    width: 16
                                    height: 16

                                    source: trayItem.modelData.icon

                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }


                                // ─────────────────────────────
                                // INPUT
                                // ─────────────────────────────

                                MouseArea {
                                    id: trayMouse

                                    anchors.fill: parent

                                    acceptedButtons:
                                    Qt.LeftButton
                                    | Qt.RightButton
                                    | Qt.MiddleButton

                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: function(mouse) {

                                        // LEFT CLICK
                                        if (mouse.button === Qt.LeftButton) {

                                            if (
                                                trayItem.modelData.onlyMenu
                                                && trayItem.modelData.hasMenu
                                            ) {
                                                trayMenu.openMenu()
                                            } else {
                                                trayItem.modelData.activate()
                                            }

                                            return
                                        }


                                        // RIGHT CLICK
                                        if (mouse.button === Qt.RightButton) {

                                            if (trayItem.modelData.hasMenu)
                                                trayMenu.openMenu()

                                                return
                                        }


                                        // MIDDLE CLICK
                                        if (mouse.button === Qt.MiddleButton) {
                                            trayItem.modelData.secondaryActivate()
                                        }
                                    }
                                }
                            }
                        }
                    }


                    // ─────────────────────
                    // NETWORK
                    // ─────────────────────

                    Rectangle {
                        width: 1
                        height: 26

                        color: colors.border
                    }

                    Item {
                        id: networkBlock

                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 54
                        Layout.preferredHeight: 30

                        readonly property var devices:
                        Networking.devices
                        ? Networking.devices.values
                        : []

                        readonly property var activeDevice: {
                            // Ethernet wins when both are connected.
                            for (let i = 0; i < devices.length; ++i) {
                                if (
                                    devices[i].connected
                                    && devices[i].type === DeviceType.Wired
                                ) {
                                    return devices[i]
                                }
                            }

                            // Otherwise Wi-Fi.
                            for (let i = 0; i < devices.length; ++i) {
                                if (
                                    devices[i].connected
                                    && devices[i].type === DeviceType.Wifi
                                ) {
                                    return devices[i]
                                }
                            }

                            return null
                        }

                        readonly property bool online:
                        activeDevice !== null

                        readonly property bool wifi:
                        activeDevice !== null
                        && activeDevice.type === DeviceType.Wifi

                        readonly property string connectionType:
                        !online
                        ? "NET"
                        : wifi
                        ? "WIFI"
                        : "ETH"

                        Column {
                            anchors.centerIn: parent

                            width: parent.width

                            spacing: -1

                            Text {
                                text: networkBlock.connectionType

                                color:
                                !networkBlock.online
                                ? colors.red
                                : networkBlock.wifi
                                ? colors.blue
                                : colors.teal

                                font.family: "monospace"
                                font.pixelSize: 8
                                font.bold: true
                            }

                            Text {
                                text:
                                networkBlock.online
                                ? "ONLINE"
                                : "OFFLINE"

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 8
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Quickshell.execDetached([
                                    "nm-connection-editor"
                                ])
                            }
                        }
                    }

                    // ─────────────────────
                    // BATTERY
                    // ─────────────────────

                    Rectangle {
                        width: 1
                        height: 26

                        color: colors.border
                    }

                    Item {
                        id: batteryBlock

                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 32

                        property real batteryLevel:
                        UPower.displayDevice.ready
                        ? UPower.displayDevice.percentage * 100
                        : -1

                        Column {
                            anchors.centerIn: parent

                            spacing: 2

                            Row {
                                spacing: 8

                                Text {
                                    text:
                                    UPower.onBattery
                                    ? "BAT"
                                    : "CHG"

                                    color:
                                    UPower.onBattery
                                    && batteryBlock.batteryLevel >= 0
                                    && batteryBlock.batteryLevel <= 20
                                    ? colors.red
                                    : UPower.onBattery
                                    ? colors.yellow
                                    : colors.teal

                                    font.family: "monospace"
                                    font.pixelSize: 8
                                    font.bold: true
                                }

                                Text {
                                    text:
                                    batteryBlock.batteryLevel >= 0
                                    ? Math.round(
                                        batteryBlock.batteryLevel
                                    ) + "%"
                                    : "--%"

                                    color: colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                }
                            }

                            Row {
                                spacing: 2

                                transform: Translate {
                                    y: 2
                                }

                                Repeater {
                                    model: 8

                                    Rectangle {
                                        required property int index

                                        width: 5
                                        height: 4

                                        property int activeSegments:
                                        batteryBlock.batteryLevel >= 0
                                        ? Math.ceil(
                                            batteryBlock.batteryLevel / 12.5
                                        )
                                        : 0

                                        color:
                                        index >= activeSegments
                                        ? colors.border
                                        : !UPower.onBattery
                                        ? colors.teal
                                        : batteryBlock.batteryLevel <= 20
                                        ? colors.red
                                        : colors.yellow
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

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

                    // ─────────────────────
                    // CLOCK
                    // ─────────────────────

                    Rectangle {
                        width: 1
                        height: 26

                        color: colors.border
                    }

                    Item {
                        id: clockBlock

                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 76
                        Layout.preferredHeight: 34


                        // DATE // small telemetry label
                        Text {
                            anchors {
                                top: parent.top
                                right: parent.right
                            }

                            text: Qt.formatDateTime(
                                clock.date,
                                "dd MMM"
                            ).toUpperCase()

                            color: colors.muted

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.6
                        }


                        // CLOCK
                        Text {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }

                            // Very slight visual drop.
                            transform: Translate {
                                y: 3
                            }

                            text: Qt.formatDateTime(
                                clock.date,
                                "HH:mm"
                            )

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 16
                            font.bold: true
                            font.letterSpacing: 1
                        }


                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (!topbarWindow.calendarOpen)
                                    topbarWindow.resetCalendarMonth()

                                    topbarWindow.calendarOpen =
                                    !topbarWindow.calendarOpen
                            }
                        }
                    }
                }
            }

            // =================================================
            // CALENDAR POPUP
            // =================================================

            PopupWindow {
                id: calendarPopup

                visible: topbarWindow.calendarOpen

                anchor.window: topbarWindow

                anchor.rect.x:
                topbarWindow.width - width - 16

                anchor.rect.y:
                topbarWindow.height

                implicitWidth: 276
                implicitHeight: 286

                color: "transparent"

                grabFocus: true

                onVisibleChanged: {
                    if (!visible)
                        topbarWindow.calendarOpen = false
                }

                Rectangle {
                    anchors.fill: parent

                    color: colors.background

                    border.width: 1
                    border.color: colors.border

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top

                        width: 92
                        height: 3

                        color: colors.red
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 98
                        anchors.top: parent.top

                        width: 34
                        height: 3

                        color: colors.yellow
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 138
                        anchors.top: parent.top

                        width: 18
                        height: 3

                        color: colors.blue
                    }

                    ColumnLayout {
                        anchors.fill: parent

                        anchors.margins: 14

                        spacing: 0

                        Text {
                            text:
                            colors.systemName.toUpperCase()
                            + " // CALENDAR"

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.bold: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 5

                            Text {
                                text: "<"

                                color:
                                previousMonthMouse.containsMouse
                                ? colors.yellow
                                : colors.muted

                                font.family: "monospace"
                                font.pixelSize: 14
                                font.bold: true

                                MouseArea {
                                    id: previousMonthMouse

                                    anchors.fill: parent
                                    anchors.margins: -6

                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked:
                                    topbarWindow.shiftCalendarMonth(-1)
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text:
                                topbarWindow.calendarTitle()

                                color: colors.text

                                font.family: "monospace"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: ">"

                                color:
                                nextMonthMouse.containsMouse
                                ? colors.yellow
                                : colors.muted

                                font.family: "monospace"
                                font.pixelSize: 14
                                font.bold: true

                                MouseArea {
                                    id: nextMonthMouse

                                    anchors.fill: parent
                                    anchors.margins: -6

                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked:
                                    topbarWindow.shiftCalendarMonth(1)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            Layout.bottomMargin: 8

                            height: 1

                            color: colors.border
                        }

                        Grid {
                            Layout.alignment:
                            Qt.AlignHCenter

                            columns: 7

                            columnSpacing: 4
                            rowSpacing: 4

                            Repeater {
                                model: [
                                    "MO", "TU", "WE", "TH",
                                    "FR", "SA", "SU"
                                ]

                                Text {
                                    required property var modelData

                                    width: 30
                                    height: 18

                                    text: modelData

                                    horizontalAlignment:
                                    Text.AlignHCenter

                                    verticalAlignment:
                                    Text.AlignVCenter

                                    color: colors.blue

                                    font.family: "monospace"
                                    font.pixelSize: 7
                                    font.bold: true
                                }
                            }

                            Repeater {
                                model: 42

                                Rectangle {
                                    required property int index

                                    width: 30
                                    height: 25

                                    readonly property int day:
                                    index
                                    - topbarWindow.calendarOffset
                                    + 1

                                    readonly property bool valid:
                                    day >= 1
                                    && day
                                    <= topbarWindow.calendarDays

                                    readonly property bool today:
                                    valid
                                    && day === clock.date.getDate()
                                    && topbarWindow.calendarMonth
                                    .getMonth()
                                    === clock.date.getMonth()
                                    && topbarWindow.calendarMonth
                                    .getFullYear()
                                    === clock.date.getFullYear()

                                    color:
                                    today
                                    ? colors.red
                                    : "transparent"

                                    border.width:
                                    valid && !today
                                    ? 1
                                    : 0

                                    border.color: colors.border

                                    Text {
                                        anchors.centerIn: parent

                                        text:
                                        parent.valid
                                        ? parent.day
                                        : ""

                                        color:
                                        parent.today
                                        ? colors.background
                                        : colors.text

                                        font.family: "monospace"
                                        font.pixelSize: 8
                                        font.bold: parent.today
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.bottomMargin: 8

                            height: 1

                            color: colors.border
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text:
                                "TODAY // "
                                + Qt.formatDateTime(
                                    clock.date,
                                    "dd MMM"
                                ).toUpperCase()

                                color: colors.teal

                                font.family: "monospace"
                                font.pixelSize: 8
                                font.bold: true
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "CLICK OUTSIDE // CLOSE"

                                color: colors.muted

                                font.family: "monospace"
                                font.pixelSize: 7
                            }
                        }
                    }
                }
            }
        }
    }
}
