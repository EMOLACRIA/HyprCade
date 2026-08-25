import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Layouts

import "../../Components"
import "../../Data"

Scope {
    id: root

    property bool outputPickerOpen: false
    property bool opened: false
    property bool windowVisible: false
    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0

    Palette { id: colors }

    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property string outputName: root.audioSink ? (root.audioSink.description || root.audioSink.nickname || root.audioSink.name || "UNKNOWN OUTPUT") : "NO OUTPUT"
    readonly property int volumePercent: root.audioSink && root.audioSink.audio ? Math.round(root.audioSink.audio.volume * 100) : 0
    readonly property bool audioMuted: root.audioSink && root.audioSink.audio ? root.audioSink.audio.muted : false

    function sinkLabel(node) {
        return (node.description || node.nickname || node.name || "").toLowerCase()
    }

    function isLaptopSink(node) {
        const label = sinkLabel(node)
        return label.includes("speaker") || label.includes("hoparlör") || label.includes("analog stereo") || label.includes("built-in") || label.includes("internal")
    }

    function isPicunSink(node) {
        const label = sinkLabel(node)
        return label.includes("picun") || label.includes("g2")
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
                .filter(node => node && node.audio && node.isSink && !node.isStream && root.isAllowedSink(node))
                .sort((a, b) => (root.isPicunSink(a) ? 1 : 0) - (root.isPicunSink(b) ? 1 : 0))
        }
    }

    PwObjectTracker { objects: [root.audioSink] }

    Process {
        running: true
        command: ["bash", Quickshell.shellPath("../../../scripts/system-stats.sh")]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|")
                if (parts.length !== 3)
                    return
                const cpu = parseInt(parts[0])
                const ram = parseInt(parts[1])
                const disk = parseInt(parts[2])
                if (!isNaN(cpu)) root.cpuUsage = cpu
                if (!isNaN(ram)) root.ramUsage = ram
                if (!isNaN(disk)) root.diskUsage = disk
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    readonly property var players: Mpris.players ? Mpris.players.values : []
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
        if (root.opened) root.closePanel()
        else root.openPanel()
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
        target: "rightpanel"
        function toggle(): void { root.togglePanel() }
        function open(): void { root.openPanel() }
        function close(): void { root.closePanel() }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: root.windowVisible

            anchors { top: true; bottom: true; right: true }
            margins { top: 64; bottom: 18; right: 0 }

            implicitWidth: 388
            exclusiveZone: 0
            color: "transparent"

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 372
                x: root.opened ? 0 : 388

                Behavior on x {
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                }

                color: colors.background
                border.width: 1
                border.color: colors.border

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    color: "transparent"
                    border.width: 1
                    border.color: colors.panelAlt
                    opacity: 0.75
                }

                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 90
                    height: 1
                    color: colors.yellow
                    opacity: 0.55
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 22
                    anchors.bottomMargin: 18
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Column {
                            spacing: 1
                            Text {
                                text: "STATUS"
                                color: colors.yellow
                                font.family: "serif"
                                font.pixelSize: 15
                                font.bold: true
                                font.letterSpacing: 1.3
                            }
                            Text {
                                text: "TARNISHED  //  01"
                                color: colors.muted
                                font.family: "serif"
                                font.pixelSize: 8
                                font.letterSpacing: 0.9
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Column {
                            spacing: 0
                            Text {
                                anchors.right: parent.right
                                text: "✦"
                                color: colors.yellow
                                font.family: "serif"
                                font.pixelSize: 16
                            }
                            Text {
                                anchors.right: parent.right
                                text: "GUIDED BY GRACE"
                                color: colors.muted
                                font.family: "serif"
                                font.pixelSize: 7
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.topMargin: 13; Layout.bottomMargin: 14; height: 1; color: colors.border }

                    Text {
                        text: Qt.formatDateTime(clock.date, "HH:mm")
                        color: colors.yellow
                        font.family: "serif"
                        font.pixelSize: 38
                        font.bold: true
                        font.letterSpacing: 2
                    }
                    Text {
                        Layout.topMargin: -2
                        text: Qt.formatDateTime(clock.date, "ddd  //  dd MMM yyyy").toUpperCase()
                        color: colors.muted
                        font.family: "serif"
                        font.pixelSize: 9
                        font.letterSpacing: 0.7
                    }

                    Rectangle { Layout.fillWidth: true; Layout.topMargin: 16; Layout.bottomMargin: 14; height: 1; color: colors.border }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "ECHOES"
                            color: colors.yellow
                            font.family: "serif"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.player ? "ACTIVE" : "SILENT"
                            color: root.player ? colors.blue : colors.muted
                            font.family: "serif"
                            font.pixelSize: 7
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        text: root.player ? (root.player.trackTitle || "UNKNOWN TRACK") : "NO ECHO REACHES THIS PLACE"
                        color: colors.text
                        font.family: "serif"
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 3
                        text: root.player ? (root.player.trackArtist || "UNKNOWN ARTIST") : "MPRIS  //  DORMANT"
                        color: colors.muted
                        font.family: "serif"
                        font.pixelSize: 9
                        font.italic: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 13
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            color: "transparent"
                            border.width: 1
                            border.color: colors.border
                            Text { anchors.centerIn: parent; text: "‹‹"; color: root.player && root.player.canGoPrevious ? colors.blue : colors.muted; font.family: "serif"; font.pixelSize: 14 }
                            MouseArea { anchors.fill: parent; enabled: root.player && root.player.canGoPrevious; cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: root.player.previous() }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            color: root.player && root.player.isPlaying ? colors.yellow : "transparent"
                            border.width: 1
                            border.color: colors.yellow
                            Text { anchors.centerIn: parent; text: root.player && root.player.isPlaying ? "PAUSE" : "PLAY"; color: root.player && root.player.isPlaying ? colors.background : colors.yellow; font.family: "serif"; font.pixelSize: 9; font.bold: true }
                            MouseArea { anchors.fill: parent; enabled: root.player && root.player.canTogglePlaying; cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: root.player.togglePlaying() }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            color: "transparent"
                            border.width: 1
                            border.color: colors.border
                            Text { anchors.centerIn: parent; text: "››"; color: root.player && root.player.canGoNext ? colors.blue : colors.muted; font.family: "serif"; font.pixelSize: 14 }
                            MouseArea { anchors.fill: parent; enabled: root.player && root.player.canGoNext; cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor; onClicked: root.player.next() }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.topMargin: 16; Layout.bottomMargin: 14; height: 1; color: colors.border }

                    Text {
                        text: "GUIDANCE"
                        color: colors.blue
                        font.family: "serif"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        spacing: 5
                        Text { Layout.fillWidth: true; text: "MPRIS      " + (root.player ? "BOUND" : "UNBOUND"); color: root.player ? colors.text : colors.muted; font.family: "serif"; font.pixelSize: 8 }
                        Text { Layout.fillWidth: true; text: "VESSEL     " + (root.player ? root.player.identity.toUpperCase() : "NONE"); color: colors.text; font.family: "serif"; font.pixelSize: 8 }
                        Text { Layout.fillWidth: true; text: "RESONANCE  " + (root.player && root.player.isPlaying ? "FLOWING" : "STILL"); color: colors.text; font.family: "serif"; font.pixelSize: 8 }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.topMargin: 15; Layout.bottomMargin: 13; height: 1; color: colors.border }

                    Text {
                        text: "BURDEN"
                        color: colors.yellow
                        font.family: "serif"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }
                    Text {
                        Layout.topMargin: 2
                        text: "THE VESSEL ENDURES  //  LIVE"
                        color: colors.muted
                        font.family: "serif"
                        font.pixelSize: 7
                        font.italic: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 11
                        spacing: 10
                        StatMeter { Layout.fillWidth: true; label: "CPU"; value: root.cpuUsage; accent: root.cpuUsage >= 85 ? colors.red : colors.blue }
                        StatMeter { Layout.fillWidth: true; label: "MEMORY"; value: root.ramUsage; accent: root.ramUsage >= 85 ? colors.red : colors.yellow }
                        StatMeter { Layout.fillWidth: true; label: "ROOT DISK"; value: root.diskUsage; accent: root.diskUsage >= 90 ? colors.red : colors.teal }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.topMargin: 15; Layout.bottomMargin: 13; height: 1; color: colors.border }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "SPIRIT TUNING"
                            color: colors.yellow
                            font.family: "serif"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.audioMuted ? "SILENCED" : root.volumePercent + "%"
                            color: root.audioMuted ? colors.red : colors.text
                            font.family: "serif"
                            font.pixelSize: 8
                            font.bold: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 9
                        height: 38
                        color: colors.panel
                        border.width: 1
                        border.color: root.outputPickerOpen ? colors.yellow : colors.border

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 94
                            text: root.outputName.toUpperCase()
                            color: colors.text
                            font.family: "serif"
                            font.pixelSize: 8
                            elide: Text.ElideRight
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.outputPickerOpen ? "CLOSE" : "CHANGE"
                            color: colors.yellow
                            font.family: "serif"
                            font.pixelSize: 7
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.outputPickerOpen = !root.outputPickerOpen
                        }
                    }

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
                                Layout.preferredHeight: 32
                                property bool active: root.audioSink && root.audioSink.id === modelData.id
                                color: active ? colors.panelAlt : "transparent"
                                border.width: 1
                                border.color: active ? colors.blue : colors.border

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: (modelData.description || modelData.nickname || modelData.name || "UNKNOWN OUTPUT").toUpperCase()
                                    color: active ? colors.blue : colors.text
                                    font.family: "serif"
                                    font.pixelSize: 8
                                    font.bold: active
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Pipewire.preferredDefaultAudioSink = modelData
                                        root.outputPickerOpen = false
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 9
                        spacing: 3
                        Repeater {
                            model: 10
                            Rectangle {
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 5
                                color: !root.audioMuted && index < Math.ceil(root.volumePercent / 10) ? colors.blue : colors.border
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!root.audioSink || !root.audioSink.audio)
                                            return
                                        root.audioSink.audio.volume = (index + 1) / 10.0
                                        root.audioSink.audio.muted = false
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 9
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 29
                            color: "transparent"
                            border.width: 1
                            border.color: colors.border
                            Text { anchors.centerIn: parent; text: "−"; color: colors.blue; font.family: "serif"; font.pixelSize: 14 }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.audioSink || !root.audioSink.audio)
                                        return
                                    root.audioSink.audio.volume = Math.max(0, root.audioSink.audio.volume - 0.10)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 29
                            color: root.audioMuted ? colors.red : "transparent"
                            border.width: 1
                            border.color: colors.yellow
                            Text { anchors.centerIn: parent; text: root.audioMuted ? "UNMUTE" : "MUTE"; color: root.audioMuted ? colors.background : colors.yellow; font.family: "serif"; font.pixelSize: 8; font.bold: true }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.audioSink || !root.audioSink.audio)
                                        return
                                    root.audioSink.audio.muted = !root.audioSink.audio.muted
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 29
                            color: "transparent"
                            border.width: 1
                            border.color: colors.border
                            Text { anchors.centerIn: parent; text: "+"; color: colors.blue; font.family: "serif"; font.pixelSize: 14 }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.audioSink || !root.audioSink.audio)
                                        return
                                    root.audioSink.audio.volume = Math.min(1.0, root.audioSink.audio.volume + 0.10)
                                    root.audioSink.audio.muted = false
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                    Rectangle { Layout.fillWidth: true; Layout.bottomMargin: 11; height: 1; color: colors.border }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "A NEW PATH OPENS."
                            color: colors.muted
                            font.family: "serif"
                            font.pixelSize: 7
                            font.italic: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "GUIDED BY GRACE"
                            color: colors.yellow
                            font.family: "serif"
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 0.7
                        }
                    }
                }
            }
        }
    }
}
