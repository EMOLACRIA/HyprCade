import QtQuick
import QtQuick.Window
import QtQuick.Layouts

Rectangle {
    id: root

    width: Screen.width
    height: Screen.height

    color: config.BackgroundColor

    // HyprCade UI scaling.
    // This is intentionally handled inside the theme instead of relying
    // on SDDM / Qt DPI environment variables.
    // ─────────────────────────────────────
    // RESPONSIVE UI CANVAS
    // ─────────────────────────────────────
    //
    // The theme was visually designed against a
    // 1600x1000 logical desktop at 1.35 UI scale.
    //
    // We therefore use the equivalent logical canvas
    // and scale it to whatever resolution SDDM sees.

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

    property string authStatus:
    "AWAITING AUTHORIZATION"

    property bool loginFailed: false

    property date currentTime: new Date()


    // ─────────────────────────────────────
    // LOGIN
    // ─────────────────────────────────────

    function login(): void {
        if (userInput.text.length === 0)
            return

            loginFailed = false
            authStatus = "AUTHENTICATING // PLEASE WAIT"

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
            root.authStatus =
            "ACCESS DENIED // INVALID CREDENTIALS"

            passwordInput.text = ""
            passwordInput.forceActiveFocus()
        }

        function onLoginSucceeded() {
            root.loginFailed = false
            root.authStatus = "ACCESS GRANTED"
        }
    }


    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.currentTime = new Date()
        }
    }


    // ─────────────────────────────────────
    // BACKGROUND
    // ─────────────────────────────────────

    Image {
        anchors.fill: parent

        source: config.Background

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }


    // General dark wash.
    Rectangle {
        anchors.fill: parent

        color: "#52070A0D"
    }


    // Slightly darker left zone for authentication UI.
    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }

        width: Math.max(
            620,
            parent.width * 0.42
        )

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0.0
                color: "#D9070A0D"
            }

            GradientStop {
                position: 0.72
                color: "#9A070A0D"
            }

            GradientStop {
                position: 1.0
                color: "#00070A0D"
            }
        }
    }


    // ─────────────────────────────────────
    // SCALED UI LAYER
    // ─────────────────────────────────────

    Item {
        id: uiLayer

        anchors.centerIn: parent

        width: root.designWidth
        height: root.designHeight

        scale: root.uiScale
        transformOrigin: Item.Center


        // ─────────────────────────────────
        // TOP LEFT BRAND
        // ─────────────────────────────────

        Column {
            anchors {
                left: parent.left
                top: parent.top

                leftMargin: 54
                topMargin: 46
            }

            spacing: 2

            Text {
                text: "HYPRCADE"

                color: config.Red

                font.family: "monospace"
                font.pixelSize: 21
                font.bold: true
                font.letterSpacing: 2
            }

            Text {
                text:
                config.SystemName
                + " // AUTHENTICATION"

                color: config.Text

                font.family: "monospace"
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1.5
            }

            Text {
                text:
                "SECURE ACCESS TERMINAL // NODE 01"

                color: config.Muted

                font.family: "monospace"
                font.pixelSize: 8
                font.letterSpacing: 0.8
            }
        }


        // ─────────────────────────────────
        // CLOCK
        // ─────────────────────────────────

        Column {
            anchors {
                right: parent.right
                top: parent.top

                rightMargin: 54
                topMargin: 42
            }

            spacing: 0

            Text {
                anchors.right: parent.right

                text: Qt.formatDateTime(
                    root.currentTime,
                    "HH:mm"
                )

                color: config.Red

                font.family: "monospace"
                font.pixelSize: 29
                font.bold: true
                font.letterSpacing: 2
            }

            Text {
                anchors.right: parent.right

                text: Qt.formatDateTime(
                    root.currentTime,
                    "ddd // dd MMM yyyy"
                ).toUpperCase()

                color: config.Text

                font.family: "monospace"
                font.pixelSize: 9
                font.bold: true
            }
        }


        // ─────────────────────────────────
        // AUTH PANEL
        // ─────────────────────────────────

        Rectangle {
            id: authPanel

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter

                leftMargin: 54
            }

            width: Math.min(
                500,
                uiLayer.width * 0.36
            )

            height: 520

            color: "#E60B1117"

            border.width: 1

            border.color:
            root.loginFailed
            ? config.Red
            : config.Border


            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                width: 5

                color:
                root.loginFailed
                ? config.Red
                : config.Yellow
            }


            ColumnLayout {
                anchors.fill: parent

                anchors {
                    leftMargin: 28
                    rightMargin: 28
                    topMargin: 26
                    bottomMargin: 24
                }

                spacing: 0


                // ─────────────────────────
                // HEADER
                // ─────────────────────────

                Text {
                    text: "AUTHORIZATION"

                    color: config.Yellow

                    font.family: "monospace"
                    font.pixelSize: 15
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Text {
                    text:
                    "IDENTITY VERIFICATION // REQUIRED"

                    color: config.Muted

                    font.family: "monospace"
                    font.pixelSize: 8
                }


                Rectangle {
                    Layout.fillWidth: true

                    Layout.topMargin: 16
                    Layout.bottomMargin: 20

                    height: 1

                    color: config.Border
                }


                // ─────────────────────────
                // USER
                // ─────────────────────────

                Text {
                    text: "USER"

                    color: config.Blue

                    font.family: "monospace"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1
                }


                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 7

                    height: 44

                    color: config.BackgroundColor

                    border.width: 1

                    border.color:
                    userInput.activeFocus
                    ? config.Blue
                    : config.Border


                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 12

                            verticalCenter:
                            parent.verticalCenter
                        }

                        text: ">"

                        color: config.Red

                        font.family: "monospace"
                        font.pixelSize: 11
                        font.bold: true
                    }


                    TextInput {
                        id: userInput

                        anchors {
                            left: parent.left
                            right: parent.right

                            verticalCenter:
                            parent.verticalCenter

                            leftMargin: 31
                            rightMargin: 12
                        }

                        text: userModel.lastUser

                        color: config.Text

                        selectionColor: config.Red

                        selectedTextColor:
                        config.BackgroundColor

                        font.family: "monospace"
                        font.pixelSize: 11
                        font.bold: true

                        KeyNavigation.tab:
                        passwordInput
                    }
                }


                // ─────────────────────────
                // PASSWORD
                // ─────────────────────────

                Text {
                    Layout.topMargin: 18

                    text: "PASSWORD"

                    color: config.Blue

                    font.family: "monospace"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1
                }


                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 7

                    height: 44

                    color: config.BackgroundColor

                    border.width: 1

                    border.color:
                    passwordInput.activeFocus
                    ? config.Red
                    : config.Border


                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: 12

                            verticalCenter:
                            parent.verticalCenter
                        }

                        text: ">"

                        color: config.Red

                        font.family: "monospace"
                        font.pixelSize: 11
                        font.bold: true
                    }


                    TextInput {
                        id: passwordInput

                        anchors {
                            left: parent.left
                            right: parent.right

                            verticalCenter:
                            parent.verticalCenter

                            leftMargin: 31
                            rightMargin: 12
                        }

                        echoMode:
                        TextInput.Password

                        passwordCharacter: "•"

                        color: config.Text

                        selectionColor: config.Red

                        selectedTextColor:
                        config.BackgroundColor

                        font.family: "monospace"
                        font.pixelSize: 12
                        font.letterSpacing: 2

                        KeyNavigation.backtab:
                        userInput

                        KeyNavigation.tab:
                        loginButton

                        Keys.onPressed:
                        function(event) {
                            if (
                                event.key
                                === Qt.Key_Return
                                ||
                                event.key
                                === Qt.Key_Enter
                            ) {
                                root.login()
                                event.accepted = true
                            }
                        }
                    }
                }


                // ─────────────────────────
                // LOGIN ERROR
                // ─────────────────────────

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 8

                    visible: root.loginFailed

                    text:
                    "WARN // AUTHENTICATION FAILURE"

                    color: config.Red

                    font.family: "monospace"
                    font.pixelSize: 8
                    font.bold: true
                }


                // ─────────────────────────
                // ACCESS BUTTON
                // ─────────────────────────

                Rectangle {
                    id: loginButton

                    Layout.fillWidth: true
                    Layout.topMargin: 20

                    height: 44

                    color:
                    loginMouse.containsMouse
                    ? config.Red
                    : "transparent"

                    border.width: 1
                    border.color: config.Red

                    focus: false


                    Text {
                        anchors.centerIn: parent

                        text:
                        "[ ACCESS SYSTEM ]"

                        color:
                        loginMouse.containsMouse
                        ? config.BackgroundColor
                        : config.Red

                        font.family: "monospace"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }


                    MouseArea {
                        id: loginMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        onClicked:
                        root.login()
                    }
                }


                Item {
                    Layout.fillHeight: true
                }


                // ─────────────────────────
                // TELEMETRY
                // ─────────────────────────

                Rectangle {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 14

                    height: 1

                    color: config.Border
                }


                Column {
                    Layout.fillWidth: true

                    spacing: 6

                    Text {
                        text:
                        "SESSION      // HYPRLAND"

                        color: config.Text

                        font.family: "monospace"
                        font.pixelSize: 9
                    }

                    Text {
                        text:
                        "NODE         // LOCAL"

                        color: config.Text

                        font.family: "monospace"
                        font.pixelSize: 9
                    }

                    Text {
                        text:
                        "STATUS       // "
                        + root.authStatus

                        color:
                        root.loginFailed
                        ? config.Red
                        : config.Teal

                        font.family: "monospace"
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }
        }


        // ─────────────────────────────────
        // BOTTOM DECORATION
        // ─────────────────────────────────

        Text {
            anchors {
                left: parent.left
                bottom: parent.bottom

                leftMargin: 54
                bottomMargin: 34
            }

            text:
            "BEBOP SYS. // AUTH NODE 01"

            color: config.Red

            font.family: "monospace"
            font.pixelSize: 9
            font.bold: true
        }


        Text {
            anchors {
                right: parent.right
                bottom: parent.bottom

                rightMargin: 54
                bottomMargin: 34
            }

            text:
            "SEE YOU SPACE COWBOY"

            color: config.Text

            font.family: "monospace"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.5
        }
    }


    Component.onCompleted: {
        if (userInput.text.length > 0)
            passwordInput.forceActiveFocus()
            else
                userInput.forceActiveFocus()
    }
}
