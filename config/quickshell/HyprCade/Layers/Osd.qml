import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Layouts

import "../Data"

Scope {
    id: root

    property bool opened: false
    property bool windowVisible: false
    property bool audioReady: false

    property string mode: "audio"
    property int brightnessPercent: 0

    readonly property bool displayMode:
    root.mode === "display"

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

    readonly property int currentPercent:
    root.displayMode
    ? root.brightnessPercent
    : root.volumePercent

    Palette {
        id: colors
    }

    PwObjectTracker {
        objects: [root.audioSink]
    }


    // ─────────────────────────────────────
    // SHOW / HIDE
    // ─────────────────────────────────────

    function reveal(): void {
        hideWindowTimer.stop()

        root.windowVisible = true
        root.opened = true

        hideTimer.restart()
    }

    function showAudio(): void {
        if (!root.audioReady)
            return

            root.mode = "audio"
            root.reveal()
    }

    function showBrightness(value: int): void {
        root.mode = "display"

        root.brightnessPercent =
        Math.max(0, Math.min(100, value))

        root.reveal()
    }


    // ─────────────────────────────────────
    // IPC
    // ─────────────────────────────────────

    IpcHandler {
        target: "osd"

        function brightness(value: int): void {
            root.showBrightness(value)
        }
    }


    // ─────────────────────────────────────
    // AUDIO WATCH
    // ─────────────────────────────────────

    onVolumePercentChanged: {
        root.showAudio()
    }

    onAudioMutedChanged: {
        root.showAudio()
    }

    onOutputNameChanged: {
        root.showAudio()
    }


    // PipeWire startup değişiklikleri OSD açmasın.
    Timer {
        interval: 1000
        running: true
        repeat: false

        onTriggered: {
            root.audioReady = true
        }
    }

    Timer {
        id: hideTimer

        interval: 1400

        onTriggered: {
            root.opened = false
            hideWindowTimer.restart()
        }
    }

    Timer {
        id: hideWindowTimer

        interval: 180

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }


    // ─────────────────────────────────────
    // WINDOW
    // ─────────────────────────────────────

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            visible: root.windowVisible

            anchors {
                bottom: true
            }

            margins {
                bottom: 34
            }

            implicitWidth: 380
            implicitHeight: 106

            exclusiveZone: 0
            focusable: false

            color: "transparent"

            mask: Region {}

            Rectangle {
                id: card

                width: 360
                height: 92

                x: 10
                y: root.opened ? 0 : 12

                opacity: root.opened ? 1.0 : 0.0

                color: colors.background

                border.width: 1
                border.color: {
                    if (root.displayMode)
                        return colors.blue

                        if (root.audioMuted)
                            return colors.red

                            return colors.border
                }

                Behavior on y {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                    }
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    anchors.topMargin: 11
                    anchors.bottomMargin: 10

                    spacing: 0


                    // HEADER
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true

                            text: root.displayMode
                            ? "DISPLAY // INTERNAL PANEL"
                            : "AUDIO // "
                            + root.outputName.toUpperCase()

                            color: colors.text

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true

                            elide: Text.ElideRight
                        }

                        Text {
                            text: {
                                if (root.displayMode)
                                    return "LUM "
                                    + root.brightnessPercent
                                    + "%"

                                    if (root.audioMuted)
                                        return "MUTED"

                                        return "VOL "
                                        + root.volumePercent
                                        + "%"
                            }

                            color: {
                                if (root.displayMode)
                                    return colors.blue

                                    if (root.audioMuted)
                                        return colors.red

                                        return colors.yellow
                            }

                            font.family: "monospace"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }


                    // METER
                    Row {
                        id: meter

                        Layout.fillWidth: true
                        Layout.topMargin: 10

                        spacing: 4

                        Repeater {
                            model: 10

                            Rectangle {
                                required property int index

                                width:
                                (meter.width - meter.spacing * 9)
                                / 10

                                height: 7

                                color: {
                                    if (!root.displayMode
                                        && root.audioMuted)
                                        return colors.border

                                        if (index
                                            < Math.ceil(
                                                root.currentPercent / 10
                                            )) {
                                            return root.displayMode
                                            ? colors.blue
                                            : colors.yellow
                                            }

                                            return colors.border
                                }
                            }
                        }
                    }


                    // FOOTER
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        Text {
                            text: {
                                if (root.displayMode)
                                    return "LUMINANCE // ACTIVE"

                                    if (root.audioMuted)
                                        return "SIGNAL LOST"

                                        return "SIGNAL // ACTIVE"
                            }

                            color: {
                                if (root.displayMode)
                                    return colors.teal

                                    if (root.audioMuted)
                                        return colors.red

                                        return colors.blue
                            }

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.displayMode
                            ? "BEBOP DISPLAY SYSTEM"
                            : "BEBOP AUDIO SYSTEM"

                            color: colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.letterSpacing: 0.5
                        }
                    }
                }
            }
        }
    }
}
