import QtQuick
import QtQuick.Layouts

import "../Data"

Item {
    id: root

    required property string label
    required property int value

    property color accent: colors.blue

    implicitHeight: 34
    Layout.preferredHeight: 34

    Palette {
        id: colors
    }

    Text {
        anchors.left: parent.left
        anchors.top: parent.top

        text: root.label

        color: root.accent

        font.family: "monospace"
        font.pixelSize: 10
        font.bold: true
        font.letterSpacing: 1
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top

        text: root.value + "%"

        color: colors.text

        font.family: "monospace"
        font.pixelSize: 10
        font.bold: true
    }

    Row {
        id: bars

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 6
        spacing: 3

        Repeater {
            model: 10

            Rectangle {
                required property int index

                width: (
                    bars.width
                    - bars.spacing * 9
                ) / 10

                height: 6

                color:
                index < Math.ceil(root.value / 10)
                ? root.accent
                : colors.border
            }
        }
    }
}
