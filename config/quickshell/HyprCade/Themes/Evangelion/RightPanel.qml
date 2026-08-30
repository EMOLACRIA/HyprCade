import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Layouts

import "../../Data"

Scope {
    id: root

    property bool opened: false
    property bool windowVisible: false
    property bool outputPickerOpen: false

    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0

    readonly property var audioSink:
    Pipewire.defaultAudioSink

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

    readonly property string outputName:
    root.audioSink
    ? (
        root.audioSink.description
        || root.audioSink.nickname
        || root.audioSink.name
        || "UNKNOWN OUTPUT"
    )
    : "NO OUTPUT"

    Palette {
        id: colors
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

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

        return (
            label.includes("speaker")
            || label.includes("hoparlör")
            || label.includes("analog stereo")
            || label.includes("built-in")
            || label.includes("internal")
        )
    }

    function isPicunSink(node) {
        const label = sinkLabel(node)

        return (
            label.includes("picun")
            || label.includes("g2")
        )
    }

    function isAllowedSink(node) {
        return (
            isLaptopSink(node)
            || isPicunSink(node)
        )
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
                && root.isAllowedSink(node)
                )
                .sort((a, b) => {
                    const aPicun =
                    root.isPicunSink(a) ? 1 : 0

                    const bPicun =
                    root.isPicunSink(b) ? 1 : 0

                    return aPicun - bPicun
                })
        }
    }

    PwObjectTracker {
        objects: [root.audioSink]
    }

    Process {
        id: statsProcess

        running: true

        command: [
            "bash",
            Quickshell.shellPath(
                "../../../scripts/system-stats.sh"
            )
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts =
                data.trim().split("|")

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

    readonly property var players:
    Mpris.players
    ? Mpris.players.values
    : []

    readonly property var player: {
        for (
            let i = 0;
        i < players.length;
        ++i
        ) {
            const identity =
            (
                players[i].identity
                || ""
            ).toLowerCase()

            if (identity.includes("spotify"))
                return players[i]
        }

        for (
            let i = 0;
        i < players.length;
        ++i
        ) {
            if (players[i].isPlaying)
                return players[i]
        }

        return (
            players.length > 0
            ? players[0]
            : null
        )
    }

    function openPanel(): void {
        hideTimer.stop()

        root.windowVisible = true
        root.opened = true
    }

    function closePanel(): void {
        root.opened = false
        root.outputPickerOpen = false

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
                top: 48
                bottom: 18
                right: 0
            }

            implicitWidth: 392

            exclusiveZone: 0
            color: "transparent"

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                width: 378

                x:
                root.opened
                ? 0
                : 392

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
                    color: "#191919"
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        topMargin: 18
                        bottomMargin: 16
                        leftMargin: 19
                        rightMargin: 19
                    }

                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: -2

                            Text {
                                text: "MAGI SYSTEM"

                                color: "#D8D8D8"

                                font.family: "monospace"
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 1.3
                            }

                            Text {
                                text: "DIAGNOSTIC CONSOLE"

                                color: "#666666"

                                font.family: "monospace"
                                font.pixelSize: 7
                                font.letterSpacing: 0.7
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Column {
                            spacing: -2

                            Text {
                                anchors.right: parent.right

                                text: "ONLINE"

                                color: "#777777"

                                font.family: "monospace"
                                font.pixelSize: 7
                                font.bold: true
                            }

                            Text {
                                anchors.right: parent.right

                                text: "●"

                                color: colors.red
                                font.pixelSize: 7
                            }
                        }
                    }

                    Divider {
                        Layout.topMargin: 12
                        Layout.bottomMargin: 13
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Column {
                            spacing: -3

                            Text {
                                text:
                                Qt.formatDateTime(
                                    clock.date,
                                    "HH:mm:ss"
                                )

                                color: "#DADADA"

                                font.family: "monospace"
                                font.pixelSize: 28
                                font.bold: true
                                font.letterSpacing: 1.4
                            }

                            Text {
                                text:
                                Qt.formatDateTime(
                                    clock.date,
                                    "ddd // dd MMM yyyy"
                                ).toUpperCase()

                                color: "#555555"

                                font.family: "monospace"
                                font.pixelSize: 7
                                font.letterSpacing: 0.6
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Column {
                            spacing: -1

                            Text {
                                anchors.right: parent.right

                                text: "SYSTEM STATE"

                                color: "#555555"

                                font.family: "monospace"
                                font.pixelSize: 7
                            }

                            Text {
                                anchors.right: parent.right

                                text: "NOMINAL"

                                color: "#B6B6B6"

                                font.family: "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Divider {
                        Layout.topMargin: 13
                        Layout.bottomMargin: 13
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "MPRIS LINK"

                            color: "#666666"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            root.player
                            ? "ACTIVE"
                            : "STANDBY"

                            color:
                            root.player
                            ? "#777777"
                            : "#444444"

                            font.family: "monospace"
                            font.pixelSize: 7
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        text:
                        root.player
                        ? (
                            root.player.trackTitle
                            || "UNKNOWN TRACK"
                        )
                        : "NO SIGNAL"

                        color: "#CFCFCF"

                        font.family: "monospace"
                        font.pixelSize: 12
                        font.bold: true

                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 2

                        text:
                        root.player
                        ? (
                            root.player.trackArtist
                            || "UNKNOWN ARTIST"
                        )
                        : "PLAYER OFFLINE"

                        color: "#555555"

                        font.family: "monospace"
                        font.pixelSize: 7

                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 5

                        MediaButton {
                            Layout.fillWidth: true

                            label: "<<"

                            enabledState:
                            root.player
                            && root.player.canGoPrevious

                            onActivated: {
                                if (root.player)
                                    root.player.previous()
                            }
                        }

                        MediaButton {
                            Layout.preferredWidth: 120

                            label:
                            root.player
                            && root.player.isPlaying
                            ? "PAUSE"
                            : "PLAY"

                            enabledState:
                            root.player
                            && root.player.canTogglePlaying

                            emphasized: true

                            onActivated: {
                                if (root.player)
                                    root.player.togglePlaying()
                            }
                        }

                        MediaButton {
                            Layout.fillWidth: true

                            label: ">>"

                            enabledState:
                            root.player
                            && root.player.canGoNext

                            onActivated: {
                                if (root.player)
                                    root.player.next()
                            }
                        }
                    }

                    Divider {
                        Layout.topMargin: 14
                        Layout.bottomMargin: 13
                    }

                    Text {
                        text: "RESOURCE DIAGNOSTICS"

                        color: "#666666"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 11

                        DiagnosticLine {
                            Layout.fillWidth: true

                            label: "CPU"
                            value: root.cpuUsage

                            critical:
                            root.cpuUsage >= 85
                        }

                        DiagnosticLine {
                            Layout.fillWidth: true

                            label: "MEMORY"
                            value: root.ramUsage

                            critical:
                            root.ramUsage >= 85
                        }

                        DiagnosticLine {
                            Layout.fillWidth: true

                            label: "ROOT"
                            value: root.diskUsage

                            critical:
                            root.diskUsage >= 90
                        }
                    }

                    Divider {
                        Layout.topMargin: 14
                        Layout.bottomMargin: 13
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "AUDIO CHANNEL"

                            color: "#666666"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            root.audioMuted
                            ? "MUTED"
                            : root.volumePercent + "%"

                            color:
                            root.audioMuted
                            ? colors.red
                            : "#777777"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        height: 34

                        color: "#0E0E0E"

                        border.width: 1

                        border.color:
                        root.outputPickerOpen
                        ? "#3A3A3A"
                        : "#222222"

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 9
                                verticalCenter: parent.verticalCenter
                            }

                            width: parent.width - 76

                            text:
                            root.outputName.toUpperCase()

                            color: "#A0A0A0"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true

                            elide: Text.ElideRight
                        }

                        Text {
                            anchors {
                                right: parent.right
                                rightMargin: 9
                                verticalCenter: parent.verticalCenter
                            }

                            text:
                            root.outputPickerOpen
                            ? "CLOSE"
                            : "CHANGE"

                            color: colors.red

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                            Qt.PointingHandCursor

                            onClicked: {
                                root.outputPickerOpen =
                                !root.outputPickerOpen
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        Layout.topMargin:
                        visible ? 5 : 0

                        visible:
                        root.outputPickerOpen

                        spacing: 3

                        Repeater {
                            model: audioOutputModel

                            Rectangle {
                                required property var modelData

                                Layout.fillWidth: true
                                height: 31

                                property bool active:
                                root.audioSink
                                && root.audioSink.id
                                === modelData.id

                                color:
                                active
                                ? "#111111"
                                : "transparent"

                                border.width: 1

                                border.color:
                                active
                                ? "#3A3A3A"
                                : "#222222"

                                Text {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 9
                                        verticalCenter:
                                        parent.verticalCenter
                                    }

                                    width: parent.width - 18

                                    text:
                                    (
                                        modelData.description
                                        || modelData.nickname
                                        || modelData.name
                                        || "OUTPUT"
                                    ).toUpperCase()

                                    color:
                                    active
                                    ? "#B0B0B0"
                                    : "#777777"

                                    font.family: "monospace"
                                    font.pixelSize: 7

                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        Pipewire
                                        .preferredDefaultAudioSink =
                                        modelData

                                        root.outputPickerOpen =
                                        false
                                    }
                                }
                            }
                        }
                    }

                    // ====================================================
                    // VOLUME METER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        Text {
                            text:
                            root.audioMuted
                            ? "MUTED"
                            : "VOLUME"

                            color:
                            root.audioMuted
                            ? colors.red
                            : "#666666"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                            root.volumePercent + "%"

                            color: "#777777"

                            font.family: "monospace"
                            font.pixelSize: 7
                            font.bold: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 6

                        spacing: 3

                        Repeater {
                            model: 10

                            Rectangle {
                                required property int index

                                Layout.fillWidth: true

                                height: 4

                                color:
                                !root.audioMuted
                                && index
                                < Math.ceil(
                                    root.volumePercent
                                    / 10
                                )
                                ? colors.red
                                : "#262626"

                                MouseArea {
                                    anchors.fill: parent

                                    cursorShape:
                                    Qt.PointingHandCursor

                                    onClicked: {
                                        if (
                                            !root.audioSink
                                            || !root.audioSink.audio
                                        )
                                            return

                                            root.audioSink.audio.volume =
                                            (index + 1) / 10.0

                                            root.audioSink.audio.muted =
                                            false
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true

                            height: 30

                            color: "transparent"

                            border.width: 1
                            border.color: "#262626"

                            Text {
                                anchors.centerIn: parent

                                text: "−"

                                color: "#8A8A8A"

                                font.family: "monospace"
                                font.pixelSize: 13
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked: {
                                    if (
                                        root.audioSink
                                        && root.audioSink.audio
                                    ) {
                                        root.audioSink.audio.volume =
                                        Math.max(
                                            0,
                                            root.audioSink
                                            .audio.volume
                                            - 0.10
                                        )
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 126

                            height: 30

                            color:
                            root.audioMuted
                            ? colors.red
                            : "transparent"

                            border.width: 1

                            border.color:
                            root.audioMuted
                            ? colors.red
                            : "#262626"

                            Text {
                                anchors.centerIn: parent

                                text:
                                root.audioMuted
                                ? "UNMUTE"
                                : "MUTE"

                                color:
                                root.audioMuted
                                ? "#0A0A0A"
                                : "#8A8A8A"

                                font.family: "monospace"
                                font.pixelSize: 8
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked: {
                                    if (
                                        root.audioSink
                                        && root.audioSink.audio
                                    ) {
                                        root.audioSink.audio.muted =
                                        !root.audioSink
                                        .audio.muted
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true

                            height: 30

                            color: "transparent"

                            border.width: 1
                            border.color: "#262626"

                            Text {
                                anchors.centerIn: parent

                                text: "+"

                                color: "#8A8A8A"

                                font.family: "monospace"
                                font.pixelSize: 13
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                Qt.PointingHandCursor

                                onClicked: {
                                    if (
                                        root.audioSink
                                        && root.audioSink.audio
                                    ) {
                                        root.audioSink.audio.volume =
                                        Math.min(
                                            1,
                                            root.audioSink
                                            .audio.volume
                                            + 0.10
                                        )
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Divider {
                        Layout.bottomMargin: 12
                    }

                    Text {
                        text: "MAGI AUTHORITY"

                        color: "#555555"

                        font.family: "monospace"
                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        spacing: 6

                        MagiNode {
                            Layout.fillWidth: true

                            name: "MELCHIOR"
                            index: "01"
                        }

                        MagiNode {
                            Layout.fillWidth: true

                            name: "BALTHASAR"
                            index: "02"
                        }

                        MagiNode {
                            Layout.fillWidth: true

                            name: "CASPER"
                            index: "03"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        Text {
                            text: "NERV // INTERNAL SYSTEM"

                            color: "#444444"

                            font.family: "monospace"
                            font.pixelSize: 6
                            font.letterSpacing: 0.4
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "ALL NODES NOMINAL"

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
            }
        }
    }

    component Divider: Rectangle {
        Layout.fillWidth: true

        implicitHeight: 1
        color: "#242424"
    }

    component DiagnosticLine: ColumnLayout {
        required property string label
        required property int value

        property bool critical: false

        spacing: 4

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: label

                color: "#777777"

                font.family: "monospace"
                font.pixelSize: 7
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: value + "%"

                color:
                critical
                ? colors.red
                : "#777777"

                font.family: "monospace"
                font.pixelSize: 7
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true

            height: 3
            color: "#171717"

            Rectangle {
                width:
                parent.width
                * Math.max(
                    0,
                    Math.min(100, value)
                )
                / 100

                height: parent.height

                color:
                critical
                ? colors.red
                : "#6A6A6A"
            }
        }
    }

    component MediaButton: Rectangle {
        property string label: ""
        property bool enabledState: true
        property bool emphasized: false

        signal activated()

        implicitHeight: 30

        color:
        mouse.containsMouse
        ? "#111111"
        : "transparent"

        border.width: 1

        border.color:
        emphasized
        ? "#343434"
        : "#252525"

        opacity:
        enabledState
        ? 1.0
        : 0.35

        Text {
            anchors.centerIn: parent

            text: label

            color:
            emphasized
            ? "#C8C8C8"
            : "#777777"

            font.family: "monospace"
            font.pixelSize: 8
            font.bold: true
        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true

            enabled: parent.enabledState

            cursorShape:
            enabled
            ? Qt.PointingHandCursor
            : Qt.ArrowCursor

            onClicked:
            parent.activated()
        }
    }

    component MagiNode: Rectangle {
        required property string name
        required property string index

        implicitHeight: 42

        color: "#0D0D0D"

        border.width: 1
        border.color: "#252525"

        Column {
            anchors.centerIn: parent

            spacing: -1

            Text {
                anchors.horizontalCenter:
                parent.horizontalCenter

                text: index

                color: colors.red

                font.family: "monospace"
                font.pixelSize: 6
            }

            Text {
                anchors.horizontalCenter:
                parent.horizontalCenter

                text: name

                color: "#747474"

                font.family: "monospace"
                font.pixelSize: 7
                font.bold: true
            }
        }
    }
}
