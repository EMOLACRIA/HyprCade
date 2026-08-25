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

    IpcHandler {
        target: "osd"

        function brightness(value: int): void {
            root.showBrightness(value)
        }
    }

    onVolumePercentChanged: root.showAudio()
    onAudioMutedChanged: root.showAudio()
    onOutputNameChanged: root.showAudio()

    Timer {
        interval: 1000
        running: true
        repeat: false

        onTriggered:
            root.audioReady = true
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
                bottom: 36
            }

            implicitWidth: 420
            implicitHeight: 94

            exclusiveZone: 0
            focusable: false

            color: "transparent"

            mask: Region {}

            Rectangle {
                id: card

                width: 400
                height: 78

                x: 10

                y:
                    root.opened
                    ? 0
                    : 10

                opacity:
                    root.opened
                    ? 1.0
                    : 0.0

                color: colors.background

                border.width: 1

                border.color:
                    !root.displayMode
                    && root.audioMuted
                    ? colors.red
                    : colors.border

                Behavior on y {
                    NumberAnimation {
                        duration: 170
                        easing.type:
                            Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5

                    color: "transparent"

                    border.width: 1
                    border.color: colors.panelAlt
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    width: 84
                    height: 1

                    color:
                        root.displayMode
                        ? colors.blue
                        : colors.yellow

                    opacity: 0.65
                }

                ColumnLayout {
                    anchors.fill: parent

                    anchors {
                        leftMargin: 16
                        rightMargin: 16
                        topMargin: 10
                        bottomMargin: 9
                    }

                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true

                            text:
                                root.displayMode
                                ? "LANTERN  //  LUMINANCE"
                                : "SPIRIT TUNING  //  "
                                    + root.outputName.toUpperCase()

                            color: colors.text

                            font.family: "serif"
                            font.pixelSize: 8
                            font.bold: true
                            font.letterSpacing: 0.6

                            elide: Text.ElideRight
                        }

                        Text {
                            text:
                                root.displayMode
                                ? root.brightnessPercent + "%"
                                : root.audioMuted
                                    ? "SILENCED"
                                    : root.volumePercent + "%"

                            color:
                                root.displayMode
                                ? colors.blue
                                : root.audioMuted
                                    ? colors.red
                                    : colors.yellow

                            font.family: "serif"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        Layout.preferredHeight: 7

                        Rectangle {
                            anchors.fill: parent

                            color: colors.panelAlt

                            border.width: 1
                            border.color: colors.border
                        }

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                                margins: 1
                            }

                            width:
                                (parent.width - 2)
                                * Math.max(
                                    0,
                                    Math.min(
                                        100,
                                        root.currentPercent
                                    )
                                )
                                / 100

                            color:
                                !root.displayMode
                                && root.audioMuted
                                ? colors.muted
                                : root.displayMode
                                    ? colors.blue
                                    : colors.yellow
                        }

                        Rectangle {
                            visible:
                                !root.displayMode
                                && root.audioMuted

                            anchors.centerIn: parent

                            width: parent.width - 12
                            height: 1

                            color: colors.red
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8

                        Text {
                            text:
                                root.displayMode
                                ? "GUIDANCE OF LIGHT"
                                : root.audioMuted
                                    ? "NO ECHO REMAINS"
                                    : "ECHOES FLOW"

                            color:
                                root.displayMode
                                ? colors.blue
                                : root.audioMuted
                                    ? colors.red
                                    : colors.muted

                            font.family: "serif"
                            font.pixelSize: 7
                            font.italic: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "✦  GUIDED BY GRACE"

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
}
