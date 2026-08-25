import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../Data"

Scope {
    id: root

    property var menu: null
    property var anchorItem: null
    property string title: "MENU"

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

        const nextStack = menuStack.slice()
        nextStack.push(currentMenu)

        menuStack = nextStack
        currentMenu = entry
    }

    function goBack(): void {
        if (menuStack.length === 0)
            return

        const nextStack = menuStack.slice()

        currentMenu = nextStack.pop()
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

        anchor.item: root.anchorItem

        anchor.edges:
            Edges.Bottom | Edges.Right

        anchor.gravity:
            Edges.Bottom | Edges.Left

        implicitWidth: 282

        implicitHeight: Math.min(
            430,
            70 + menuList.contentHeight
        )

        color: "transparent"
        grabFocus: true

        onVisibleChanged: {
            if (!visible && root.menuOpen)
                root.closeMenu()
        }

        Rectangle {
            anchors.fill: parent

            color: colors.background

            radius: 5

            border.width: 1
            border.color: colors.border

            Rectangle {
                anchors.fill: parent
                anchors.margins: 5

                color: "transparent"

                radius: 3

                border.width: 1
                border.color: colors.panelAlt
            }

            Rectangle {
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }

                width: 82
                height: 1

                color: colors.yellow
                opacity: 0.75
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 11

                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    Text {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }

                        text:
                            root.menuStack.length > 0
                            ? "‹  RETURN"
                            : "GUIDANCE"

                        color:
                            backMouse.containsMouse
                            ? colors.yellow
                            : (
                                root.menuStack.length > 0
                                ? colors.text
                                : colors.yellow
                            )

                        font.family: "serif"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    Text {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }

                        width: 170

                        text: root.title.toUpperCase()

                        horizontalAlignment:
                            Text.AlignRight

                        elide: Text.ElideRight

                        color: colors.muted

                        font.family: "serif"
                        font.pixelSize: 8
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
                            ? 92
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
                    Layout.preferredHeight: 1

                    color: colors.border
                }

                ListView {
                    id: menuList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 7

                    clip: true
                    spacing: 2

                    boundsBehavior:
                        Flickable.StopAtBounds

                    model: menuOpener.children

                    delegate: Item {
                        id: entryItem

                        required property QsMenuEntry modelData

                        width: ListView.view.width

                        height:
                            modelData.isSeparator
                            ? 10
                            : 32

                        Rectangle {
                            visible:
                                entryItem.modelData.isSeparator

                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            height: 1
                            color: colors.border
                        }

                        Rectangle {
                            visible:
                                !entryItem.modelData.isSeparator

                            anchors.fill: parent

                            radius: 3

                            color:
                                entryMouse.containsMouse
                                && entryItem.modelData.enabled
                                ? colors.panelAlt
                                : "transparent"

                            border.width:
                                entryMouse.containsMouse
                                && entryItem.modelData.enabled
                                ? 1
                                : 0

                            border.color:
                                entryItem.modelData.hasChildren
                                ? colors.blue
                                : colors.border
                        }

                        Text {
                            visible:
                                !entryItem.modelData.isSeparator

                            anchors {
                                left: parent.left
                                leftMargin: 7
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            width: 18

                            text:
                                entryItem.modelData.buttonType
                                    === QsMenuButtonType.CheckBox
                                ? (
                                    entryItem.modelData.checkState
                                        === Qt.Checked
                                    ? "✦"
                                    : "·"
                                )
                                : entryItem.modelData.buttonType
                                    === QsMenuButtonType.RadioButton
                                ? (
                                    entryItem.modelData.checkState
                                        === Qt.Checked
                                    ? "●"
                                    : "○"
                                )
                                : entryMouse.containsMouse
                                    && entryItem.modelData.enabled
                                ? "›"
                                : ""

                            color:
                                entryItem.modelData.enabled
                                ? colors.yellow
                                : colors.muted

                            font.family: "serif"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Image {
                            visible:
                                !entryItem.modelData.isSeparator
                                && entryItem.modelData.icon !== ""

                            anchors {
                                left: parent.left
                                leftMargin: 29
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            width: 14
                            height: 14

                            source:
                                entryItem.modelData.icon

                            sourceSize.width: width
                            sourceSize.height: height

                            fillMode:
                                Image.PreserveAspectFit

                            smooth: true

                            opacity:
                                entryItem.modelData.enabled
                                ? 0.9
                                : 0.35
                        }

                        Text {
                            visible:
                                !entryItem.modelData.isSeparator

                            anchors {
                                left: parent.left
                                right: arrowText.left

                                leftMargin:
                                    entryItem.modelData.icon !== ""
                                    ? 50
                                    : 29

                                rightMargin: 8

                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text:
                                entryItem.modelData.text

                            elide: Text.ElideRight

                            color:
                                entryItem.modelData.enabled
                                ? colors.text
                                : colors.muted

                            opacity:
                                entryItem.modelData.enabled
                                ? 1.0
                                : 0.42

                            font.family: "serif"
                            font.pixelSize: 9

                            font.bold:
                                entryMouse.containsMouse
                                && entryItem.modelData.enabled
                        }

                        Text {
                            id: arrowText

                            visible:
                                !entryItem.modelData.isSeparator
                                && entryItem.modelData.hasChildren

                            anchors {
                                right: parent.right
                                rightMargin: 8
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: "›"

                            color:
                                entryMouse.containsMouse
                                ? colors.yellow
                                : colors.blue

                            font.family: "serif"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            id: entryMouse

                            anchors.fill: parent

                            enabled:
                                !entryItem.modelData.isSeparator
                                && entryItem.modelData.enabled

                            hoverEnabled: true

                            cursorShape:
                                enabled
                                ? Qt.PointingHandCursor
                                : Qt.ArrowCursor

                            onClicked: {
                                if (
                                    entryItem.modelData.hasChildren
                                ) {
                                    root.enterMenu(
                                        entryItem.modelData
                                    )

                                    return
                                }

                                entryItem.modelData.triggered()
                                root.closeMenu()
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 5

                    text:
                        root.menuStack.length > 0
                        ? "RETURN TO THE PREVIOUS PATH"
                        : "ESC  //  CLOSE"

                    horizontalAlignment:
                        Text.AlignRight

                    color: colors.muted

                    font.family: "serif"
                    font.pixelSize: 6
                    font.italic: true
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
