import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

import QtQuick
import QtQuick.Layouts

import "../../Data"

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
    ? Math.round(
        root.audioSink.audio.volume * 100
    )
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

    // ============================================================
    // SHOW / HIDE
    // ============================================================

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
        Math.max(
            0,
            Math.min(100, value)
        )

        root.reveal()
    }

    // ============================================================
    // IPC
    // ============================================================

    IpcHandler {
        target: "osd"

        function brightness(value: int): void {
            root.showBrightness(value)
        }
    }

    // ============================================================
    // AUDIO WATCH
    // ============================================================

    onVolumePercentChanged: {
        root.showAudio()
    }

    onAudioMutedChanged: {
        root.showAudio()
    }

    onOutputNameChanged: {
        root.showAudio()
    }

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

        interval: 1300

        onTriggered: {
            root.opened = false
            hideWindowTimer.restart()
        }
    }

    Timer {
        id: hideWindowTimer

        interval: 160

        onTriggered: {
            if (!root.opened)
                root.windowVisible = false
        }
    }

    // ============================================================
    // WINDOW
    // ============================================================

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

            implicitWidth: 350
            implicitHeight: 88

            exclusiveZone: 0
            focusable: false

            color: "transparent"

            mask: Region {}

            Rectangle {
                id: osdSurface

                width: 330
                height: 74

                x: 10

                y:
                root.opened
                ? 0
                : 10

                opacity:
                root.opened
                ? 1.0
                : 0.0

                color: "#0A0A0A"

                border.width: 1
                border.color: "#292929"

                Behavior on y {
                    NumberAnimation {
                        duration: 150
                        easing.type:
                        Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                    }

                    width: 2

                    color:
                    root.audioMuted
                    ? colors.red
                    : "#343434"
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        leftMargin: 13
                        rightMargin: 13
                        topMargin: 10
                        bottomMargin: 9
                    }

                    spacing: 0

                    // ====================================================
                    // HEADER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                            root.displayMode
                            ? "DISPLAY"
                            : "AUDIO"

                            color: "#AFAFAF"

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.bold: true
                            font.letterSpacing: 0.8
                        }

                        Text {
                            text: "//"

                            color: "#383838"

                            font.family: "monospace"
                            font.pixelSize: 7
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                            root.displayMode
                            ? "INTERNAL PANEL"
                            : root.outputName
                            .toUpperCase()

                            color: "#555555"

                            font.family: "monospace"
                            font.pixelSize: 6

                            elide: Text.ElideRight
                        }

                        Text {
                            text: {
                                if (
                                    !root.displayMode
                                    && root.audioMuted
                                )
                                    return "MUTED"

                                    return (
                                        root.currentPercent
                                        + "%"
                                    )
                            }

                            color:
                            root.audioMuted
                            && !root.displayMode
                            ? colors.red
                            : "#BEBEBE"

                            font.family: "monospace"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    // ====================================================
                    // METER
                    // ====================================================

                    Row {
                        id: meter

                        Layout.fillWidth: true
                        Layout.topMargin: 9

                        spacing: 3

                        Repeater {
                            model: 20

                            Rectangle {
                                required property int index

                                width:
                                (
                                    meter.width
                                    - meter.spacing * 19
                                )
                                / 20

                                height: 4

                                color: {
                                    if (
                                        !root.displayMode
                                        && root.audioMuted
                                    )
                                        return "#252525"

                                        if (
                                            index
                                            < Math.ceil(
                                                root.currentPercent
                                                / 5
                                            )
                                        ) {
                                            return (
                                                root.displayMode
                                                ? "#858585"
                                                : colors.red
                                            )
                                        }

                                        return "#252525"
                                }
                            }
                        }
                    }

                    // ====================================================
                    // FOOTER
                    // ====================================================

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        Text {
                            text: {
                                if (root.displayMode)
                                    return "LUMINANCE"

                                    if (root.audioMuted)
                                        return "SIGNAL CLOSED"

                                        return "OUTPUT LEVEL"
                            }

                            color:
                            root.audioMuted
                            && !root.displayMode
                            ? colors.red
                            : "#4F4F4F"

                            font.family: "monospace"
                            font.pixelSize: 6
                            font.bold: true
                            font.letterSpacing: 0.5
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "NERV // MAGI"

                            color: "#454545"

                            font.family: "monospace"
                            font.pixelSize: 6
                            font.letterSpacing: 0.5
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
}
