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

    readonly property var roman: [
        "I", "II", "III", "IV", "V", "VI"
    ]

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
                + "  "
                + calendarMonth.getFullYear()
            }

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 48
            exclusiveZone: 48

            color: "transparent"

            Rectangle {
                anchors.fill: parent

                color: colors.background

                border.width: 1
                border.color: colors.border

                // Thin grace line at the bottom.
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    height: 1
                    color: colors.yellow
                    opacity: 0.55
                }

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    spacing: 14

                    // =====================================================
                    // IDENTITY
                    // =====================================================

                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 9

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: "✦"
                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 19
                        }

                        Column {
                            spacing: -1

                            Text {
                                text: "H Y P R C A D E"

                                color: colors.text

                                font.family: "serif"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.1
                            }

                            Text {
                                text: "THE LANDS BETWEEN  //  01"

                                color: colors.muted

                                font.family: "serif"
                                font.pixelSize: 7
                                font.letterSpacing: 0.9
                            }
                        }
                    }

                    GraceSeparator { lineColor: colors.border }

                    // =====================================================
                    // SITE OF GRACE / RUNES
                    // =====================================================

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter

                        implicitWidth: 154
                        implicitHeight: 30

                        color: "transparent"

                        border.width: 1
                        border.color: colors.border

                        Column {
                            anchors.centerIn: parent
                            spacing: -1

                            Text {
                                anchors.horizontalCenter:
                                parent.horizontalCenter

                                text: "SITE OF GRACE"

                                color: colors.yellow

                                font.family: "serif"
                                font.pixelSize: 8
                                font.bold: true
                                font.letterSpacing: 1
                            }

                            Text {
                                anchors.horizontalCenter:
                                parent.horizontalCenter

                                text: "4,250,000  RUNES"

                                color: colors.text

                                font.family: "serif"
                                font.pixelSize: 8
                                font.letterSpacing: 0.8
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // =====================================================
                    // WORKSPACES
                    // =====================================================

                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 5

                        Repeater {
                            model: 6

                            Rectangle {
                                id: workspaceBox

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

                                width: 34
                                height: 28

                                color:
                                focused
                                ? colors.yellow
                                : "transparent"

                                border.width: 1

                                border.color:
                                urgent
                                ? colors.red
                                : focused
                                ? colors.yellow
                                : occupied
                                ? colors.text
                                : colors.border

                                opacity:
                                focused || occupied || urgent
                                ? 1.0
                                : 0.5

                                Text {
                                    anchors.centerIn: parent

                                    text: root.roman[
                                        workspaceBox.index
                                    ]

                                    color:
                                    workspaceBox.focused
                                    ? colors.background
                                    : workspaceBox.urgent
                                    ? colors.red
                                    : workspaceBox.occupied
                                    ? colors.text
                                    : colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 10
                                    font.bold:
                                    workspaceBox.focused
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        if (
                                            workspaceBox.workspace
                                            !== null
                                        ) {
                                            workspaceBox.workspace
                                            .activate()
                                            return
                                        }

                                        if (Hyprland.usingLua) {
                                            Hyprland.dispatch(
                                                'hl.dsp.focus({ workspace = "'
                                                + workspaceBox.workspaceId
                                                + '" })'
                                            )
                                        } else {
                                            Hyprland.dispatch(
                                                "workspace "
                                                + workspaceBox.workspaceId
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

                    // =====================================================
                    // TRAY
                    // =====================================================

                    GraceSeparator {
                        visible:
                        SystemTray.items.values.length > 0

                        lineColor: colors.border
                    }

                    Row {
                        visible:
                        SystemTray.items.values.length > 0

                        Layout.alignment: Qt.AlignVCenter

                        spacing: 4

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

                                border.color: colors.border

                                GraceTrayMenu {
                                    id: trayMenu

                                    menu: trayItem.modelData.menu

                                    title:
                                    trayItem.modelData.title
                                    || trayItem.modelData.id
                                    || "TRAY"

                                    anchorItem: trayItem
                                }

                                Image {
                                    anchors.centerIn: parent

                                    width: 15
                                    height: 15

                                    source:
                                    trayItem.modelData.icon

                                    fillMode:
                                    Image.PreserveAspectFit

                                    smooth: true
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

                                    onClicked: function(mouse) {
                                        if (
                                            mouse.button
                                            === Qt.LeftButton
                                        ) {
                                            if (
                                                trayItem.modelData
                                                .onlyMenu
                                                && trayItem.modelData
                                                .hasMenu
                                            ) {
                                                trayMenu.openMenu()
                                            } else {
                                                trayItem.modelData
                                                .activate()
                                            }

                                            return
                                        }

                                        if (
                                            mouse.button
                                            === Qt.RightButton
                                        ) {
                                            if (
                                                trayItem.modelData
                                                .hasMenu
                                            ) {
                                                trayMenu.openMenu()
                                            }

                                            return
                                        }

                                        if (
                                            mouse.button
                                            === Qt.MiddleButton
                                        ) {
                                            trayItem.modelData
                                            .secondaryActivate()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    GraceSeparator { lineColor: colors.border }

                    // =====================================================
                    // NETWORK
                    // =====================================================

                    Item {
                        id: networkBlock

                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 32

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
                                if (
                                    devices[i].connected
                                    && devices[i].type
                                    === DeviceType.Wired
                                ) {
                                    return devices[i]
                                }
                            }

                            for (
                                let i = 0;
                            i < devices.length;
                            ++i
                            ) {
                                if (
                                    devices[i].connected
                                    && devices[i].type
                                    === DeviceType.Wifi
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
                        && activeDevice.type
                        === DeviceType.Wifi

                        Column {
                            anchors.centerIn: parent

                            spacing: -1

                            Text {
                                text:
                                networkBlock.wifi
                                ? "ELDEN WIFI"
                                : "ELDEN NET"

                                color: colors.muted

                                font.family: "serif"
                                font.pixelSize: 7
                                font.letterSpacing: 0.6
                            }

                            Text {
                                text:
                                networkBlock.online
                                ? "ONLINE"
                                : "OFFLINE"

                                color:
                                networkBlock.online
                                ? colors.yellow
                                : colors.red

                                font.family: "serif"
                                font.pixelSize: 8
                                font.bold: true
                                font.letterSpacing: 0.7
                            }
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

                    GraceSeparator { lineColor: colors.border }

                    // =====================================================
                    // BATTERY
                    // =====================================================

                    Item {
                        id: batteryBlock

                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 66
                        Layout.preferredHeight: 32

                        property real batteryLevel:
                        UPower.displayDevice.ready
                        ? UPower.displayDevice.percentage
                        * 100
                        : -1

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Row {
                                spacing: 7

                                Text {
                                    text:
                                    UPower.onBattery
                                    ? "BAT"
                                    : "CHG"

                                    color: colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 7
                                }

                                Text {
                                    text:
                                    batteryBlock.batteryLevel
                                    >= 0
                                    ? Math.round(
                                        batteryBlock.batteryLevel
                                    ) + "%"
                                    : "--%"

                                    color: colors.text

                                    font.family: "serif"
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                width: 54
                                height: 3

                                color: colors.panelAlt

                                Rectangle {
                                    width:
                                    parent.width
                                    * Math.max(
                                        0,
                                        Math.min(
                                            100,
                                            batteryBlock
                                            .batteryLevel
                                        )
                                    )
                                    / 100

                                    height: parent.height

                                    color:
                                    batteryBlock.batteryLevel
                                    <= 20
                                    ? colors.red
                                    : colors.yellow
                                }
                            }
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

                    GraceSeparator { lineColor: colors.border }

                    // =====================================================
                    // CLOCK
                    // =====================================================

                    Item {
                        id: clockBlock

                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredWidth: 78
                        Layout.preferredHeight: 36

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

                            font.family: "serif"
                            font.pixelSize: 7
                            font.letterSpacing: 0.5
                        }

                        Text {
                            anchors {
                                horizontalCenter:
                                parent.horizontalCenter
                                verticalCenter:
                                parent.verticalCenter
                            }

                            transform: Translate {
                                y: 4
                            }

                            text: Qt.formatDateTime(
                                clock.date,
                                "HH:mm"
                            )

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 16
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                            Qt.PointingHandCursor

                            onClicked: {
                                if (!topbarWindow.calendarOpen)
                                    topbarWindow
                                    .resetCalendarMonth()

                                    topbarWindow.calendarOpen =
                                    !topbarWindow.calendarOpen
                            }
                        }
                    }
                }
            }

            // =========================================================
            // CALENDAR
            // =========================================================

            PopupWindow {
                id: calendarPopup

                visible: topbarWindow.calendarOpen

                anchor.window: topbarWindow

                anchor.rect.x:
                topbarWindow.width
                - implicitWidth
                - 18

                anchor.rect.y:
                topbarWindow.height

                implicitWidth: 284
                implicitHeight: 292

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

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14

                        spacing: 0

                        Text {
                            text: "THE LANDS BETWEEN"

                            color: colors.yellow

                            font.family: "serif"
                            font.pixelSize: 9
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 7

                            Text {
                                text: "‹"

                                color:
                                prevMouse.containsMouse
                                ? colors.yellow
                                : colors.muted

                                font.family: "serif"
                                font.pixelSize: 18

                                MouseArea {
                                    id: prevMouse

                                    anchors.fill: parent
                                    anchors.margins: -6

                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked:
                                    topbarWindow
                                    .shiftCalendarMonth(-1)
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text:
                                topbarWindow.calendarTitle()

                                color: colors.text

                                font.family: "serif"
                                font.pixelSize: 11
                                font.bold: true
                                font.letterSpacing: 0.8
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "›"

                                color:
                                nextMouse.containsMouse
                                ? colors.yellow
                                : colors.muted

                                font.family: "serif"
                                font.pixelSize: 18

                                MouseArea {
                                    id: nextMouse

                                    anchors.fill: parent
                                    anchors.margins: -6

                                    hoverEnabled: true

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked:
                                    topbarWindow
                                    .shiftCalendarMonth(1)
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
                            Layout.alignment: Qt.AlignHCenter

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

                                    width: 31
                                    height: 18

                                    text: modelData

                                    horizontalAlignment:
                                    Text.AlignHCenter

                                    verticalAlignment:
                                    Text.AlignVCenter

                                    color: colors.muted

                                    font.family: "serif"
                                    font.pixelSize: 7
                                    font.bold: true
                                }
                            }

                            Repeater {
                                model: 42

                                Rectangle {
                                    id: calendarDay

                                    required property int index

                                    width: 31
                                    height: 25

                                    readonly property int day:
                                    index
                                    - topbarWindow
                                    .calendarOffset
                                    + 1

                                    readonly property bool valid:
                                    day >= 1
                                    && day
                                    <= topbarWindow
                                    .calendarDays

                                    readonly property bool today:
                                    valid
                                    && day
                                    === clock.date
                                    .getDate()
                                    && topbarWindow
                                    .calendarMonth
                                    .getMonth()
                                    === clock.date
                                    .getMonth()
                                    && topbarWindow
                                    .calendarMonth
                                    .getFullYear()
                                    === clock.date
                                    .getFullYear()

                                    color:
                                    today
                                    ? colors.yellow
                                    : "transparent"

                                    border.width:
                                    valid && !today
                                    ? 1
                                    : 0

                                    border.color: colors.border

                                    Text {
                                        anchors.centerIn: parent

                                        text:
                                        calendarDay.valid
                                        ? calendarDay.day
                                        : ""

                                        color:
                                        calendarDay.today
                                        ? colors.background
                                        : colors.text

                                        font.family: "serif"
                                        font.pixelSize: 8
                                        font.bold:
                                        calendarDay.today
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
                                "GUIDED BY GRACE  //  "
                                + Qt.formatDateTime(
                                    clock.date,
                                    "dd MMM yyyy"
                                ).toUpperCase()

                                color: colors.muted

                                font.family: "serif"
                                font.pixelSize: 7
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "TRY GRACE"

                                color: colors.yellow

                                font.family: "serif"
                                font.pixelSize: 7
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }

    component GraceSeparator: Rectangle {
        property color lineColor: "#4E4128"

        width: 1
        height: 28

        color: lineColor
    }
}
