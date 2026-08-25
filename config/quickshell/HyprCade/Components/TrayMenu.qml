import Quickshell
import QtQuick
import QtQuick.Layouts

import "../Data"

Scope {
    id: root

    property var menu: null
    property var anchorItem: null
    property string title: "TRAY"

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

        implicitWidth: 268
        implicitHeight: Math.min(
            420,
            58 + menuList.contentHeight
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

            border.width: 1
            border.color: colors.border

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                width: 94
                height: 3
                color: colors.red
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.top: parent.top
                width: 36
                height: 3
                color: colors.yellow
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 142
                anchors.top: parent.top
                width: 20
                height: 3
                color: colors.blue
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        text:
                            root.menuStack.length > 0
                            ? "< BACK"
                            : colors.systemName.toUpperCase()
                                + " // TRAY"

                        color:
                            backMouse.containsMouse
                            ? colors.yellow
                            : colors.red

                        font.family: "monospace"
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 0.8
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        width: 150
                        text: root.title.toUpperCase()

                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight

                        color: colors.muted

                        font.family: "monospace"
                        font.pixelSize: 8
                        font.bold: true
                    }

                    MouseArea {
                        id: backMouse

                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        width:
                            root.menuStack.length > 0
                            ? 72
                            : 0

                        enabled:
                            root.menuStack.length > 0

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.goBack()
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
                    Layout.topMargin: 6

                    clip: true
                    spacing: 1
                    boundsBehavior: Flickable.StopAtBounds

                    model: menuOpener.children

                    delegate: Item {
                        id: entryItem

                        required property QsMenuEntry modelData

                        width: ListView.view.width
                        height:
                            modelData.isSeparator
                            ? 9
                            : 30

                        Rectangle {
                            visible: entryItem.modelData.isSeparator

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            height: 1
                            color: colors.border
                        }

                        Rectangle {
                            visible: !entryItem.modelData.isSeparator
                            anchors.fill: parent

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
                            visible: !entryItem.modelData.isSeparator

                            anchors.left: parent.left
                            anchors.leftMargin: 7
                            anchors.verticalCenter: parent.verticalCenter

                            width: 14

                            text:
                                entryItem.modelData.buttonType
                                    === QsMenuButtonType.CheckBox
                                ? (
                                    entryItem.modelData.checkState
                                        === Qt.Checked
                                    ? "[x]"
                                    : "[ ]"
                                )
                                : entryItem.modelData.buttonType
                                    === QsMenuButtonType.RadioButton
                                ? (
                                    entryItem.modelData.checkState
                                        === Qt.Checked
                                    ? "(o)"
                                    : "( )"
                                )
                                : entryMouse.containsMouse
                                    && entryItem.modelData.enabled
                                ? ">"
                                : ""

                            color:
                                entryItem.modelData.enabled
                                ? colors.red
                                : colors.muted

                            font.family: "monospace"
                            font.pixelSize: 8
                            font.bold: true
                        }

                        Image {
                            visible:
                                !entryItem.modelData.isSeparator
                                && entryItem.modelData.icon !== ""

                            anchors.left: parent.left
                            anchors.leftMargin: 27
                            anchors.verticalCenter: parent.verticalCenter

                            width: 14
                            height: 14

                            source: entryItem.modelData.icon
                            sourceSize.width: width
                            sourceSize.height: height
                            fillMode: Image.PreserveAspectFit
                            smooth: true

                            opacity:
                                entryItem.modelData.enabled
                                ? 1.0
                                : 0.4
                        }

                        Text {
                            visible: !entryItem.modelData.isSeparator

                            anchors.left: parent.left
                            anchors.leftMargin:
                                entryItem.modelData.icon !== ""
                                ? 48
                                : 27

                            anchors.right: arrowText.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter

                            text: entryItem.modelData.text
                            elide: Text.ElideRight

                            color:
                                entryItem.modelData.enabled
                                ? colors.text
                                : colors.muted

                            opacity:
                                entryItem.modelData.enabled
                                ? 1.0
                                : 0.45

                            font.family: "monospace"
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

                            anchors.right: parent.right
                            anchors.rightMargin: 7
                            anchors.verticalCenter: parent.verticalCenter

                            text: ">>"

                            color:
                                entryMouse.containsMouse
                                ? colors.yellow
                                : colors.blue

                            font.family: "monospace"
                            font.pixelSize: 8
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
                                if (entryItem.modelData.hasChildren) {
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
                    Layout.topMargin: 4

                    text:
                        root.menuStack.length > 0
                        ? "SUBMENU // CLICK < BACK TO RETURN"
                        : "SYSTEM MENU // ESC OR CLICK OUTSIDE"

                    horizontalAlignment: Text.AlignRight
                    color: colors.muted

                    font.family: "monospace"
                    font.pixelSize: 6
                    font.letterSpacing: 0.4
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
