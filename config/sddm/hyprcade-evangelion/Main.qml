import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height

    color: config.BackgroundColor

    // Match the scaling model used by the existing HyprCade SDDM themes.
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

    property string authStatus: "AWAITING AUTHORIZATION"
    property bool loginFailed: false
    property date currentTime: new Date()

    function login() {
        if (userInput.text.length === 0)
            return

            loginFailed = false
            authStatus = "VERIFYING // MAGI LINK"

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
            root.authStatus = "ACCESS DENIED"

            passwordInput.text = ""
            passwordInput.forceActiveFocus()
        }

        function onLoginSucceeded() {
            root.loginFailed = false
            root.authStatus = "AUTHORIZATION ACCEPTED"
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

    // Keep the wallpaper visible, only reduce contrast slightly.
    Rectangle {
        anchors.fill: parent
        color: "#38000000"
    }

    // Authentication-area shade only.
    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width: Math.max(
            500,
            parent.width * 0.35
        )

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0.0
                color: "#D0050607"
            }

            GradientStop {
                position: 0.70
                color: "#85050607"
            }

            GradientStop {
                position: 1.0
                color: "#00050607"
            }
        }
    }

    // ============================================================
    // UI
    // ============================================================

    Item {
        id: uiLayer

        anchors.centerIn: parent

        width: root.designWidth
        height: root.designHeight

        scale: root.uiScale
        transformOrigin: Item.Center

        // ========================================================
        // TOP LEFT
        // ========================================================

        Column {
            anchors {
                left: parent.left
                top: parent.top

                leftMargin: 48
                topMargin: 40
            }

            spacing: 0

            Text {
                text: "NERV"

                color: config.Text

                font.family: "monospace"
                font.pixelSize: 15
                font.bold: true
                font.letterSpacing: 1.8
            }

            Text {
                text: config.SystemName

                color: config.Muted

                font.family: "monospace"
                font.pixelSize: 7
                font.bold: true
                font.letterSpacing: 0.7
            }

            Text {
                text: "MAGI AUTHENTICATION TERMINAL"

                color: "#555555"

                font.family: "monospace"
                font.pixelSize: 6
                font.letterSpacing: 0.5
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top

                leftMargin: 48
                topMargin: 92
            }

            width: 110
            height: 2

            color: config.Red
        }

        // ========================================================
        // TOP RIGHT
        // ========================================================

        Column {
            anchors {
                right: parent.right
                top: parent.top

                rightMargin: 48
                topMargin: 35
            }

            spacing: 2

            Text {
                anchors.right: parent.right

                text:
                Qt.formatDateTime(
                    root.currentTime,
                    "HH:mm"
                )

                color: config.Text

                font.family: "monospace"
                font.pixelSize: 33
                font.bold: true
            }

            Text {
                anchors.right: parent.right

                text:
                Qt.formatDateTime(
                    root.currentTime,
                    "ddd // dd MMM yyyy"
                ).toUpperCase()

                color: config.Muted

                font.family: "monospace"
                font.pixelSize: 7
            }
        }

        // ========================================================
        // LOGIN TERMINAL
        // ========================================================

        ColumnLayout {
            anchors {
                left: parent.left
                bottom: parent.bottom

                leftMargin: 48
                bottomMargin: 76
            }

            width: 390
            spacing: 0

            Text {
                text: "AUTHORIZATION REQUIRED"

                color: config.Text

                font.family: "monospace"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 0.7
            }

            Text {
                Layout.topMargin: 3

                text: "LOCAL SESSION // LEVEL 01"

                color: config.Muted

                font.family: "monospace"
                font.pixelSize: 7
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.bottomMargin: 14

                height: 1

                color: config.Border
            }

            // USER
            Text {
                text: "OPERATOR"

                color: "#777777"

                font.family: "monospace"
                font.pixelSize: 7
                font.bold: true
                font.letterSpacing: 0.8
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 6

                height: 38

                color: "#D0090B0C"

                border.width: 1

                border.color:
                userInput.activeFocus
                ? "#555555"
                : config.Border

                TextInput {
                    id: userInput

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter

                        leftMargin: 12
                        rightMargin: 12
                    }

                    text: userModel.lastUser

                    color: config.Text

                    selectionColor: config.Red
                    selectedTextColor: config.BackgroundColor

                    font.family: "monospace"
                    font.pixelSize: 9
                    font.bold: true

                    KeyNavigation.tab:
                    passwordInput
                }
            }

            // PASSWORD
            Text {
                Layout.topMargin: 13

                text: "ACCESS CODE"

                color: "#777777"

                font.family: "monospace"
                font.pixelSize: 7
                font.bold: true
                font.letterSpacing: 0.8
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 6

                height: 38

                color: "#D0090B0C"

                border.width: 1

                border.color:
                root.loginFailed
                ? config.Red
                : passwordInput.activeFocus
                ? "#555555"
                : config.Border

                TextInput {
                    id: passwordInput

                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter

                        leftMargin: 12
                        rightMargin: 12
                    }

                    echoMode:
                    TextInput.Password

                    passwordCharacter: "•"

                    color: config.Text

                    selectionColor: config.Red
                    selectedTextColor: config.BackgroundColor

                    font.family: "monospace"
                    font.pixelSize: 10
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

            // STATUS
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8

                Text {
                    text: root.authStatus

                    color:
                    root.loginFailed
                    ? config.Red
                    : config.Muted

                    font.family: "monospace"
                    font.pixelSize: 6
                    font.bold: root.loginFailed
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "SESSION // HYPRLAND"

                    color: "#4B4B4B"

                    font.family: "monospace"
                    font.pixelSize: 6
                }
            }

            // LOGIN BUTTON
            Rectangle {
                id: loginButton

                Layout.fillWidth: true
                Layout.topMargin: 13

                height: 38

                color:
                loginMouse.containsMouse
                ? "#16D83A2E"
                : "#09090B0C"

                border.width: 1

                border.color:
                loginMouse.containsMouse
                ? config.Red
                : config.Border

                Text {
                    anchors.centerIn: parent

                    text: "[ AUTHORIZE ]"

                    color:
                    loginMouse.containsMouse
                    ? config.Red
                    : "#8A8A8A"

                    font.family: "monospace"
                    font.pixelSize: 8
                    font.bold: true
                    font.letterSpacing: 0.7
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

        // ========================================================
        // BOTTOM MARKINGS
        // ========================================================

        Row {
            anchors {
                left: parent.left
                bottom: parent.bottom

                leftMargin: 48
                bottomMargin: 27
            }

            spacing: 10

            Text {
                text: "MELCHIOR // NOMINAL"

                color: config.Muted

                font.family: "monospace"
                font.pixelSize: 6
            }

            Text {
                text: "BALTHASAR // NOMINAL"

                color: config.Muted

                font.family: "monospace"
                font.pixelSize: 6
            }

            Text {
                text: "CASPER // NOMINAL"

                color: config.Muted

                font.family: "monospace"
                font.pixelSize: 6
            }
        }

        Row {
            anchors {
                right: parent.right
                bottom: parent.bottom

                rightMargin: 48
                bottomMargin: 27
            }

            spacing: 7

            Text {
                text: "NERV // SECURE"

                color: config.Red

                font.family: "monospace"
                font.pixelSize: 6
                font.bold: true
            }

            Text {
                text: "●"

                color: config.Red
                font.pixelSize: 5
            }
        }
    }

    Component.onCompleted: {
        if (userInput.text.length > 0)
            passwordInput.forceActiveFocus()
            else
                userInput.forceActiveFocus()
    }
}
