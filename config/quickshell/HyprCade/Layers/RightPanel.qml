import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../Components"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../Data"

Scope {
    id: root

    property bool outputPickerOpen: false

    readonly property string outputName:
    root.audioSink
    ? (
        root.audioSink.description
        || root.audioSink.nickname
        || root.audioSink.name
        || "UNKNOWN OUTPUT"
    )
    : "NO OUTPUT"

    readonly property var audioSink: Pipewire.defaultAudioSink

    readonly property int volumePercent:
    root.audioSink
    && root.audioSink.audio
    ? Math.round(root.audioSink.audio.volume * 100)
    : 0

    readonly property bool audioMuted:
    root.audioSink
    && root.audioSink.audio
    ? root.audioSink.audio.muted
    : false

    function sinkLabel(node) {
        return (
            node.description
            || node.nickname
            || node.name
            || ""
        ).toLowerCase()
    }

    function isLaptopSink(node) {
        const label = sinkLabel(node)

        return label.includes("speaker")
        || label.includes("hoparlör")
        || label.includes("analog stereo")
        || label.includes("built-in")
        || label.includes("internal")
    }

    function isPicunSink(node) {
        const label = sinkLabel(node)

        return label.includes("picun")
        || label.includes("g2")
    }

    function isAllowedSink(node) {
        return isLaptopSink(node) || isPicunSink(node)
    }

    ScriptModel {
        id: audioOutputModel

        values: {
            if (!Pipewire.nodes)
                return []

                return [...Pipewire.nodes.values]
                .filter(node =>
                node
                && node.audio
                && node.isSink
                && !node.isStream
                && isAllowedSink(node)
                )
                .sort((a, b) => {
                    const aPicun = isPicunSink(a) ? 1 : 0
                    const bPicun = isPicunSink(b) ? 1 : 0
                    return aPicun - bPicun
                })
        }
    }

    PwObjectTracker {
        objects: [root.audioSink]
    }

    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0

    property bool opened: false
    property bool windowVisible: false

    Palette {
        id: colors
    }

    Process {
        id: statsProcess

        running: true

        command: [
            "bash",
            Quickshell.shellPath("../../../scripts/system-stats.sh")
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")

                if (parts.length !== 3)
                    return

                    const cpu = parseInt(parts[0])
                    const ram = parseInt(parts[1])
                    const disk = parseInt(parts[2])

                    if (!isNaN(cpu))
                        root.cpuUsage = cpu

                        if (!isNaN(ram))
                            root.ramUsage = ram

                            if (!isNaN(disk))
                                root.diskUsage = disk
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    readonly property var players:
    Mpris.players ? Mpris.players.values : []

    readonly property var player: {
        for (let i = 0; i < players.length; ++i) {
            const identity = (players[i].identity || "").toLowerCase()

            if (identity.includes("spotify"))
                return players[i]
        }

        for (let i = 0; i < players.length; ++i) {
            if (players[i].isPlaying)
                return players[i]
        }

        return players.length > 0 ? players[0] : null
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
        target: "rightpanel"

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
                right: true
            }

            margins {
                top: 64
                bottom: 14
                right: 0
            }

            implicitWidth: 372

            exclusiveZone: 0
            color: "transparent"

            Rectangle {
                id: panel

                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: 360

                x: root.opened ? 0 : 372

                Behavior on x {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

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

                    // HEADER

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: 1

                            Text {
                                text: "STATUS"

                                color: colors.red
                                font.family: "monospace"
                                font.pixelSize: 15
                                font.bold: true
                                font.letterSpacing: 1.2
                            }

                            Text {
                                text: "DECK // 01"

                                color: colors.text
                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "ONLINE"

                            color: colors.blue
                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 14
                        Layout.bottomMargin: 16

                        height: 1
                        color: colors.border
                    }

                    // CLOCK

                    Text {
                        text: Qt.formatDateTime(clock.date, "HH:mm")

                        color: colors.red

                        font.family: "monospace"
                        font.pixelSize: 38
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: Qt.formatDateTime(
                            clock.date,
                            "ddd // dd MMM yyyy"
                        ).toUpperCase()

                        color: colors.muted

                        font.family: "monospace"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 18
                        Layout.bottomMargin: 16

                        height: 1
                        color: colors.border
                    }

                    // NOW PLAYING

                    Text {
                        text: "NOW PLAYING"

                        color: colors.yellow

                        font.family: "monospace"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        text: root.player
                        ? (root.player.trackTitle || "UNKNOWN TRACK")
                        : "NO SIGNAL"

                        color: colors.text

                        font.family: "monospace"
                        font.pixelSize: 15
                        font.bold: true

                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 3

                        text: root.player
                        ? (root.player.trackArtist || "UNKNOWN ARTIST")
                        : "MPRIS // STANDBY"

                        color: colors.muted

                        font.family: "monospace"
                        font.pixelSize: 10

                        elide: Text.ElideRight
                    }

                    Row {
                        Layout.topMargin: 14

                        spacing: 8

                        Rectangle {
                            width: 72
                            height: 32

                            color: "transparent"
                            border.width: 1
                            border.color: colors.border

                            Text {
                                anchors.centerIn: parent

                                text: "<<"

                                color: root.player
                                && root.player.canGoPrevious
                                ? colors.blue
                                : colors.muted

                                font.family: "monospace"
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent

                                enabled:
                                root.player
                                && root.player.canGoPrevious

                                cursorShape:
                                enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                                onClicked:
                                root.player.previous()
                            }
                        }

                        Rectangle {
                            width: 140
                            height: 32

                            color: root.player
                            && root.player.isPlaying
                            ? colors.red
                            : "transparent"

                            border.width: 1
                            border.color: colors.red

                            Text {
                                anchors.centerIn: parent

                                text: root.player
                                && root.player.isPlaying
                                ? "[ PAUSE ]"
                                : "[ PLAY ]"

                                color: root.player
                                && root.player.isPlaying
                                ? colors.background
                                : colors.red

                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent

                                enabled:
                                root.player
                                && root.player.canTogglePlaying

                                cursorShape:
                                enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                                onClicked:
                                root.player.togglePlaying()
                            }
                        }

                        Rectangle {
                            width: 72
                            height: 32

                            color: "transparent"
                            border.width: 1
                            border.color: colors.border

                            Text {
                                anchors.centerIn: parent

                                text: ">>"

                                color: root.player
                                && root.player.canGoNext
                                ? colors.blue
                                : colors.muted

                                font.family: "monospace"
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent

                                enabled:
                                root.player
                                && root.player.canGoNext

                                cursorShape:
                                enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                                onClicked:
                                root.player.next()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 18
                        Layout.bottomMargin: 16

                        height: 1
                        color: colors.border
                    }

                    // STATUS BLOCK

                    // ──────────────────────────
                    // COMMUNICATION
                    // ──────────────────────────

                    Text {
                        text: "COMMUNICATION"

                        color: colors.blue

                        font.family: "monospace"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 7

                        Text {
                            Layout.fillWidth: true

                            text: "MPRIS LINK   // "
                            + (root.player ? "ACTIVE" : "OFFLINE")

                            color: root.player
                            ? colors.text
                            : colors.muted

                            font.family: "monospace"
                            font.pixelSize: 10
                        }

                        Text {
                            Layout.fillWidth: true

                            text: "PLAYER       // "
                            + (root.player
                            ? root.player.identity.toUpperCase()
                            : "NONE")

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 10
                        }

                        Text {
                            Layout.fillWidth: true

                            text: "TRACK LINK   // "
                            + (root.player
                            && root.player.isPlaying
                            ? "RUNNING"
                            : "STANDBY")

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 10
                        }
                    }


                    // ──────────────────────────
                    // SYSTEM LOAD
                    // ──────────────────────────

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 18
                        Layout.bottomMargin: 16

                        height: 1
                        color: colors.border
                    }

                    Text {
                        text: "SYSTEM LOAD"

                        color: colors.yellow

                        font.family: "monospace"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        Layout.topMargin: 3

                        text: "RESOURCE TELEMETRY // LIVE"

                        color: colors.muted

                        font.family: "monospace"
                        font.pixelSize: 8
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 14

                        spacing: 13

                        StatMeter {
                            Layout.fillWidth: true

                            label: "CPU"
                            value: root.cpuUsage

                            accent: root.cpuUsage >= 85
                            ? colors.red
                            : colors.blue
                        }

                        StatMeter {
                            Layout.fillWidth: true

                            label: "MEMORY"
                            value: root.ramUsage

                            accent: root.ramUsage >= 85
                            ? colors.red
                            : colors.yellow
                        }

                        StatMeter {
                            Layout.fillWidth: true

                            label: "ROOT DISK"
                            value: root.diskUsage

                            accent: root.diskUsage >= 90
                            ? colors.red
                            : colors.teal
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 18
                        Layout.bottomMargin: 16

                        height: 1
                        color: colors.border
                    }

                    Text {
                        text: "AUDIO OUTPUT"

                        color: colors.red

                        font.family: "monospace"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }


                    // ──────────────────────────
                    // OUTPUT DEVICE
                    // ──────────────────────────

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        height: 38

                        color: colors.panel

                        border.width: 1
                        border.color: root.outputPickerOpen
                        ? colors.yellow
                        : colors.border

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            width: parent.width - 92

                            text: root.outputName.toUpperCase()

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true

                            elide: Text.ElideRight
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter

                            text: root.outputPickerOpen
                            ? "[ CLOSE ]"
                            : "[ CHANGE ]"

                            color: colors.yellow

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.outputPickerOpen =
                                !root.outputPickerOpen
                            }
                        }
                    }


                    // ──────────────────────────
                    // OUTPUT LIST
                    // ──────────────────────────

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: visible ? 6 : 0

                        visible: root.outputPickerOpen
                        spacing: 4

                        Repeater {
                            model: audioOutputModel

                            Rectangle {
                                required property var modelData

                                Layout.fillWidth: true
                                Layout.preferredHeight: 34

                                property bool active:
                                root.audioSink
                                && root.audioSink.id === modelData.id

                                color: active
                                ? colors.panelAlt
                                : "transparent"

                                border.width: 1
                                border.color: active
                                ? colors.blue
                                : colors.border

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter

                                    width: 3
                                    height: 20

                                    color: active
                                    ? colors.blue
                                    : colors.muted
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12

                                    anchors.right: parent.right
                                    anchors.rightMargin: 10

                                    anchors.verticalCenter: parent.verticalCenter

                                    text: (
                                        modelData.description
                                        || modelData.nickname
                                        || modelData.name
                                        || "UNKNOWN OUTPUT"
                                    ).toUpperCase()

                                    color: active
                                    ? colors.blue
                                    : colors.text

                                    font.family: "monospace"
                                    font.pixelSize: 9
                                    font.bold: active

                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        Pipewire.preferredDefaultAudioSink =
                                        modelData

                                        root.outputPickerOpen = false
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        Text {
                            text: root.audioMuted
                            ? "MUTED"
                            : "VOLUME"

                            color: root.audioMuted
                            ? colors.red
                            : colors.text

                            font.family: "monospace"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.volumePercent + "%"

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 7

                        spacing: 3

                        Repeater {
                            model: 10

                            Rectangle {
                                required property int index

                                Layout.fillWidth: true
                                Layout.preferredHeight: 6

                                color:
                                !root.audioMuted
                                && index < Math.ceil(root.volumePercent / 10)
                                ? colors.red
                                : colors.border

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        if (!root.audioSink || !root.audioSink.audio)
                                            return

                                            root.audioSink.audio.volume =
                                            (index + 1) / 10.0

                                            root.audioSink.audio.muted = false
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30

                            color: "transparent"

                            border.width: 1
                            border.color: colors.border

                            Text {
                                anchors.centerIn: parent

                                text: "-"

                                color: colors.blue

                                font.family: "monospace"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (!root.audioSink || !root.audioSink.audio)
                                        return

                                        root.audioSink.audio.volume =
                                        Math.max(
                                            0,
                                            root.audioSink.audio.volume - 0.10
                                        )
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30

                            color: root.audioMuted
                            ? colors.red
                            : "transparent"

                            border.width: 1
                            border.color: colors.red

                            Text {
                                anchors.centerIn: parent

                                text: root.audioMuted
                                ? "UNMUTE"
                                : "MUTE"

                                color: root.audioMuted
                                ? colors.background
                                : colors.red

                                font.family: "monospace"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (!root.audioSink || !root.audioSink.audio)
                                        return

                                        root.audioSink.audio.muted =
                                        !root.audioSink.audio.muted
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 30

                            color: "transparent"

                            border.width: 1
                            border.color: colors.border

                            Text {
                                anchors.centerIn: parent

                                text: "+"

                                color: colors.blue

                                font.family: "monospace"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (!root.audioSink || !root.audioSink.audio)
                                        return

                                        root.audioSink.audio.volume =
                                        Math.min(
                                            1.0,
                                            root.audioSink.audio.volume + 0.10
                                        )

                                        root.audioSink.audio.muted = false
                                }
                            }
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
                            text: "SEE YOU SPACE COWBOY"

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.letterSpacing: 0.5
                        }
                    }
                }
            }
        }
    }
}
