import Quickshell

import QtQuick
import QtQuick.Layouts

import "../../Data"

Scope {
    id: root

    property var menu: null
    property var anchorItem: null
    property string title: "SYSTEM"

    property bool menuOpen: false
    property var currentMenu: null
    property var menuStack: []

    Palette {
        id: colors
    }

    function openMenu(): void {
        if (!menu)
            return

            menuStack = []
            currentMenu = menu
            menuOpen = true
    }

    function closeMenu(): void {
        menuOpen = false
        menuStack = []
        currentMenu = null
    }

    function enterMenu(entry): void {
        if (!entry || !entry.hasChildren)
            return

            const nextStack =
            menuStack.slice()

            nextStack.push(currentMenu)

            menuStack = nextStack
            currentMenu = entry
    }

    function goBack(): void {
        if (menuStack.length === 0)
            return

            const nextStack =
            menuStack.slice()

            currentMenu =
            nextStack.pop()

            menuStack = nextStack
    }

    QsMenuOpener {
        id: menuOpener

        menu: root.currentMenu
    }

    PopupWindow {
        id: menuPopup

        visible:
        root.menuOpen
        && root.anchorItem !== null
        && root.currentMenu !== null

        anchor.item:
        root.anchorItem

        anchor.edges:
        Edges.Bottom
        | Edges.Right

        anchor.gravity:
        Edges.Bottom
        | Edges.Left

        implicitWidth: 270

        implicitHeight:
        Math.min(
            420,
            60
            + menuList.contentHeight
        )

        color: "transparent"
        grabFocus: true

        onVisibleChanged: {
            if (
                !visible
                && root.menuOpen
            ) {
                root.closeMenu()
            }
        }

        Rectangle {
            anchors.fill: parent

            color: "#090909"

            border.width: 1
            border.color: "#292929"

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                width: 2
                color: colors.red
            }

            ColumnLayout {
                anchors.fill: parent

                anchors {
                    topMargin: 10
                    bottomMargin: 9
                    leftMargin: 12
                    rightMargin: 10
                }

                spacing: 0

                // ================================================
                // HEADER
                // ================================================

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    Text {
                        anchors {
                            left: parent.left
                            verticalCenter:
                            parent.verticalCenter
                        }

                        text:
                        root.menuStack.length > 0
                        ? "< RETURN"
                        : "NERV SYSTEM"

                        color:
                        backMouse.containsMouse
                        ? colors.red
                        : "#A8A8A8"

                        font.family:
                        "monospace"

                        font.pixelSize: 7
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    Text {
                        anchors {
                            right: parent.right
                            verticalCenter:
                            parent.verticalCenter
                        }

                        width: 155

                        text:
                        root.title
                        .toUpperCase()

                        horizontalAlignment:
                        Text.AlignRight

                        elide:
                        Text.ElideRight

                        color: "#555555"

                        font.family:
                        "monospace"

                        font.pixelSize: 7
                        font.bold: true
                    }

                    MouseArea {
                        id: backMouse

                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }

                        width:
                        root.menuStack.length > 0
                        ? 78
                        : 0

                        enabled:
                        root.menuStack.length > 0

                        hoverEnabled: true

                        cursorShape:
                        Qt.PointingHandCursor

                        onClicked:
                        root.goBack()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true

                    height: 1
                    color: "#242424"
                }

                // ================================================
                // ENTRIES
                // ================================================

                ListView {
                    id: menuList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 6

                    clip: true
                    spacing: 1

                    boundsBehavior:
                    Flickable.StopAtBounds

                    model:
                    menuOpener.children

                    delegate: Item {
                        id: entryItem

                        required property QsMenuEntry modelData

                        width:
                        ListView.view.width

                        height:
                        modelData.isSeparator
                        ? 9
                        : 30

                        Rectangle {
                            visible:
                            entryItem
                            .modelData
                            .isSeparator

                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter:
                                parent.verticalCenter
                            }

                            height: 1
                            color: "#242424"
                        }

                        Rectangle {
                            visible:
                            !entryItem
                            .modelData
                            .isSeparator

                            anchors.fill: parent

                            color:
                            entryMouse.containsMouse
                            && entryItem
                            .modelData
                            .enabled
                            ? "#111111"
                            : "transparent"

                            border.width:
                            entryMouse.containsMouse
                            && entryItem
                            .modelData
                            .enabled
                            ? 1
                            : 0

                            border.color:
                            "#303030"

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }

                                width:
                                entryMouse.containsMouse
                                && entryItem
                                .modelData
                                .enabled
                                ? 2
                                : 0

                                color: colors.red
                            }
                        }

                        // CHECKBOX / RADIO / CURSOR
                        Text {
                            visible:
                            !entryItem
                            .modelData
                            .isSeparator

                            anchors {
                                left: parent.left
                                leftMargin: 7
                                verticalCenter:
                                parent.verticalCenter
                            }

                            width: 17

                            text:
                            entryItem
                            .modelData
                            .buttonType
                            === QsMenuButtonType.CheckBox
                            ? (
                                entryItem
                                .modelData
                                .checkState
                                === Qt.Checked
                                ? "[X]"
                                : "[ ]"
                            )
                            : entryItem
                            .modelData
                            .buttonType
                            === QsMenuButtonType.RadioButton
                            ? (
                                entryItem
                                .modelData
                                .checkState
                                === Qt.Checked
                                ? "(*)"
                                : "( )"
                            )
                            : entryMouse.containsMouse
                            && entryItem
                            .modelData
                            .enabled
                            ? ">"
                            : ""

                            color:
                            entryItem
                            .modelData
                            .enabled
                            ? colors.red
                            : "#444444"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                            font.bold: true
                        }

                        Image {
                            visible:
                            !entryItem
                            .modelData
                            .isSeparator
                            && entryItem
                            .modelData
                            .icon !== ""

                            anchors {
                                left: parent.left
                                leftMargin: 28
                                verticalCenter:
                                parent.verticalCenter
                            }

                            width: 13
                            height: 13

                            source:
                            entryItem
                            .modelData
                            .icon

                            sourceSize.width:
                            width

                            sourceSize.height:
                            height

                            fillMode:
                            Image.PreserveAspectFit

                            smooth: true

                            opacity:
                            entryItem
                            .modelData
                            .enabled
                            ? 0.8
                            : 0.3
                        }

                        Text {
                            visible:
                            !entryItem
                            .modelData
                            .isSeparator

                            anchors {
                                left: parent.left
                                right: arrowText.left

                                leftMargin:
                                entryItem
                                .modelData
                                .icon !== ""
                                ? 47
                                : 28

                                rightMargin: 8

                                verticalCenter:
                                parent.verticalCenter
                            }

                            text:
                            entryItem
                            .modelData
                            .text

                            elide:
                            Text.ElideRight

                            color:
                            entryItem
                            .modelData
                            .enabled
                            ? "#A9A9A9"
                            : "#454545"

                            font.family:
                            "monospace"

                            font.pixelSize: 8

                            font.bold:
                            entryMouse.containsMouse
                            && entryItem
                            .modelData
                            .enabled
                        }

                        Text {
                            id: arrowText

                            visible:
                            !entryItem
                            .modelData
                            .isSeparator
                            && entryItem
                            .modelData
                            .hasChildren

                            anchors {
                                right: parent.right
                                rightMargin: 7

                                verticalCenter:
                                parent.verticalCenter
                            }

                            text: ">>"

                            color:
                            entryMouse.containsMouse
                            ? colors.red
                            : "#555555"

                            font.family:
                            "monospace"

                            font.pixelSize: 7
                            font.bold: true
                        }

                        MouseArea {
                            id: entryMouse

                            anchors.fill: parent

                            enabled:
                            !entryItem
                            .modelData
                            .isSeparator
                            && entryItem
                            .modelData
                            .enabled

                            hoverEnabled: true

                            cursorShape:
                            enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                            onClicked: {
                                if (
                                    entryItem
                                    .modelData
                                    .hasChildren
                                ) {
                                    root.enterMenu(
                                        entryItem
                                        .modelData
                                    )

                                    return
                                }

                                entryItem
                                .modelData
                                .triggered()

                                root.closeMenu()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 5

                    height: 1
                    color: "#242424"
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 6

                    Text {
                        text:
                        root.menuStack.length > 0
                        ? "SUBSYSTEM"
                        : "MAGI LINK"

                        color: "#444444"

                        font.family:
                        "monospace"

                        font.pixelSize: 6
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "ESC CLOSE"

                        color: "#444444"

                        font.family:
                        "monospace"

                        font.pixelSize: 6
                    }

                    Text {
                        text: "●"

                        color: colors.red
                        font.pixelSize: 5
                    }
                }
            }

            FocusScope {
                anchors.fill: parent
                focus: true

                Keys.onEscapePressed:
                root.closeMenu()
            }
        }
    }
}
