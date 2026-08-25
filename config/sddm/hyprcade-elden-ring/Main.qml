import QtQuick
import QtQuick.Window
import QtQuick.Layouts

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height

    color: config.BackgroundColor

    // Designed against the same logical canvas as the Bebop greeter
    // so both themes scale consistently on the laptop display.
    readonly property real designWidth: 1600 / 1.35
    readonly property real designHeight: 1000 / 1.35

    readonly property real uiScale: Math.min(
        root.width / designWidth,
        root.height / designHeight
    )

    property int sessionIndex:
        sessionModel.lastIndex >= 0
        ? sessionModel.lastIndex
        : 0

    property string authStatus: "AWAITING GRACE"
    property bool loginFailed: false
    property date currentTime: new Date()

    function login(): void {
        if (userInput.text.length === 0)
            return

        loginFailed = false
        authStatus = "THE SEAL YIELDS..."

        sddm.login(
            userInput.text,
            passwordInput.text,
            root.sessionIndex
        )
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.loginFailed = true
            root.authStatus = "GRACE DENIED"

            passwordInput.text = ""
            passwordInput.forceActiveFocus()
        }

        function onLoginSucceeded() {
            root.loginFailed = false
            root.authStatus = "GUIDED BY GRACE"
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered:
            root.currentTime = new Date()
    }

    // ============================================================
    // BACKGROUND
    // ============================================================

    Image {
        anchors.fill: parent

        source: config.Background
        fillMode: Image.PreserveAspectCrop

        asynchronous: true
    }

    // Very light dark wash; keep the cosmic moon visible.
    Rectangle {
        anchors.fill: parent
        color: "#4205070A"
    }

    // Gentle lower-left shade for the authentication area only.
    Rectangle {
        anchors {
            left: parent.left
            bottom: parent.bottom
            top: parent.top
        }

        width: Math.max(
            540,
            parent.width * 0.38
        )

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0.0
                color: "#B805070A"
            }

            GradientStop {
                position: 0.72
                color: "#5A05070A"
            }

            GradientStop {
                position: 1.0
                color: "#0005070A"
            }
        }
    }

    // ============================================================
    // RESPONSIVE UI LAYER
    // ============================================================

    Item {
        id: uiLayer

        anchors.centerIn: parent

        width: root.designWidth
        height: root.designHeight

        scale: root.uiScale
        transformOrigin: Item.Center

        // --------------------------------------------------------
        // TOP LEFT
        // --------------------------------------------------------

        Column {
            anchors {
                left: parent.left
                top: parent.top

                leftMargin: 52
                topMargin: 42
            }

            spacing: 1

            Text {
                text: "HYPRCADE"

                color: config.Yellow

                font.family: "serif"
                font.pixelSize: 14
                font.bold: true
                font.letterSpacing: 1.6
            }

            Text {
                text: config.SystemName

                color: config.Text

                font.family: "serif"
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 0.9
            }

            Text {
                text: "THE PATH REMAINS SEALED"

                color: config.Muted

                font.family: "serif"
                font.pixelSize: 7
                font.italic: true
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top

                leftMargin: 52
                topMargin: 92
            }

            width: 150
            height: 1

            color: config.Yellow
            opacity: 0.75
        }

        // --------------------------------------------------------
        // TOP RIGHT — CLOCK
        // --------------------------------------------------------

        Column {
            anchors {
                right: parent.right
                top: parent.top

                rightMargin: 52
                topMargin: 38
            }

            spacing: 4

            Text {
                anchors.right: parent.right

                text: Qt.formatDateTime(
                    root.currentTime,
                    "HH:mm"
                )

                color: config.Text

                font.family: "serif"
                font.pixelSize: 34
                font.bold: true
            }

            Text {
                anchors.right: parent.right

                text: Qt.formatDateTime(
                    root.currentTime,
                    "dddd  //  dd MMMM yyyy"
                ).toUpperCase()

                color: config.Muted

                font.family: "serif"
                font.pixelSize: 8
            }
        }

        // --------------------------------------------------------
        // AUTHENTICATION — LOWER LEFT
        // --------------------------------------------------------

        ColumnLayout {
            anchors {
                left: parent.left
                bottom: parent.bottom

                leftMargin: 52
                bottomMargin: 72
            }

            width: 410
            spacing: 0

            Text {
                text: "✦  SITE OF GRACE"

                color: config.Yellow

                font.family: "serif"
                font.pixelSize: 14
                font.bold: true
                font.letterSpacing: 0.8
            }

            Text {
                Layout.topMargin: 3

                text: "Touch Grace to return to the Lands Between."

                color: config.Muted

                font.family: "serif"
                font.pixelSize: 8
                font.italic: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 14
                Layout.bottomMargin: 14

                height: 1

                color: config.Border
            }

            Text {
                text: "TARNISHED"

                color: config.Blue

                font.family: "serif"
                font.pixelSize: 8
                font.bold: true
                font.letterSpacing: 1.0
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 6

                height: 40
                radius: 9

                color: "#C0090C10"

                border.width: 1

                border.color:
                    userInput.activeFocus
                    ? config.Blue
                    : config.Border

                TextInput {
                    id: userInput

                    anchors {
                        left: parent.left
                        right: parent.right

                        leftMargin: 14
                        rightMargin: 14

                        verticalCenter:
                            parent.verticalCenter
                    }

                    text: userModel.lastUser

                    color: config.Text

                    selectionColor: config.Blue
                    selectedTextColor:
                        config.BackgroundColor

                    font.family: "serif"
                    font.pixelSize: 10
                    font.bold: true

                    KeyNavigation.tab:
                        passwordInput
                }
            }

            Text {
                Layout.topMargin: 14

                text: "SEAL"

                color: config.Blue

                font.family: "serif"
                font.pixelSize: 8
                font.bold: true
                font.letterSpacing: 1.0
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 6

                height: 40
                radius: 9

                color: "#C0090C10"

                border.width: 1

                border.color:
                    root.loginFailed
                    ? config.Red
                    : passwordInput.activeFocus
                        ? config.Yellow
                        : config.Border

                TextInput {
                    id: passwordInput

                    anchors {
                        left: parent.left
                        right: parent.right

                        leftMargin: 14
                        rightMargin: 14

                        verticalCenter:
                            parent.verticalCenter
                    }

                    echoMode:
                        TextInput.Password

                    passwordCharacter: "•"

                    color: config.Text

                    selectionColor:
                        config.Yellow

                    selectedTextColor:
                        config.BackgroundColor

                    font.family: "serif"
                    font.pixelSize: 11
                    font.letterSpacing: 3

                    KeyNavigation.backtab:
                        userInput

                    KeyNavigation.tab:
                        loginButton

                    Keys.onPressed:
                        function(event) {
                            if (
                                event.key === Qt.Key_Return
                                || event.key === Qt.Key_Enter
                            ) {
                                root.login()
                                event.accepted = true
                            }
                        }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8

                Text {
                    text:
                        root.loginFailed
                        ? "GRACE DENIED"
                        : root.authStatus

                    color:
                        root.loginFailed
                        ? config.Red
                        : config.Muted

                    font.family: "serif"
                    font.pixelSize: 7
                    font.italic: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "SESSION  //  HYPRLAND"

                    color: config.Muted

                    font.family: "serif"
                    font.pixelSize: 7
                }
            }

            Rectangle {
                id: loginButton

                Layout.fillWidth: true
                Layout.topMargin: 14

                height: 40
                radius: 9

                color:
                    loginMouse.containsMouse
                    ? "#25C9A85B"
                    : "#1005070A"

                border.width: 1
                border.color: config.Yellow

                Text {
                    anchors.centerIn: parent

                    text: "ENTER THE LANDS BETWEEN"

                    color: config.Yellow

                    font.family: "serif"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 0.8
                }

                MouseArea {
                    id: loginMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked:
                        root.login()
                }
            }
        }

        // --------------------------------------------------------
        // BOTTOM MARKINGS
        // --------------------------------------------------------

        Rectangle {
            anchors {
                left: parent.left
                bottom: parent.bottom

                leftMargin: 52
                bottomMargin: 44
            }

            width: 150
            height: 1

            color: config.Blue
            opacity: 0.7
        }

        Text {
            anchors {
                left: parent.left
                bottom: parent.bottom

                leftMargin: 52
                bottomMargin: 25
            }

            text: "GUIDED BY GRACE"

            color: config.Blue

            font.family: "serif"
            font.pixelSize: 7
            font.bold: true
        }

        Text {
            anchors {
                right: parent.right
                bottom: parent.bottom

                rightMargin: 52
                bottomMargin: 25
            }

            text: "THE LANDS BETWEEN  //  AUTHENTICATION"

            color: config.Muted

            font.family: "serif"
            font.pixelSize: 7
        }
    }

    Component.onCompleted: {
        if (userInput.text.length > 0)
            passwordInput.forceActiveFocus()
        else
            userInput.forceActiveFocus()
    }
}
