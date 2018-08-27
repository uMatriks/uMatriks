import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: iconButton

    property color color
    property color pressedColor
    property color borderColor

    property string text
    property string iconName
    property int iconSize
    property int iconRotate
    property int border

    style: Item {
        width: iconButton.width
        height: iconButton.height
        implicitWidth: Math.max(units.gu(10), foreground.implicitWidth + units.gu(2))
        implicitHeight: units.gu(7)

        LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft
        LayoutMirroring.childrenInherit: true
        opacity: iconButton.enabled ? 1.0 : 0.6

        Rectangle {
            anchors.fill: parent
            color: iconButton.pressed ? iconButton.pressedColor : "transparent"
            radius: units.dp(4)

            border {
                width: iconButton.border ? iconButton.border : 0
                color: iconButton.borderColor ? iconButton.borderColor : "transparent"
            }
        }

        Row {
            id: foreground
            spacing: units.gu(1)
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left; leftMargin: units.gu(1)
                margins: units.dp(2)
                horizontalCenter: parent.horizontalCenter
            }

            Icon {
                id: icon
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: iconButton.color ? iconButton.color : "transparent"
                width: iconButton.iconSize ? iconButton.iconSize : units.gu(6); height: width
                name: iconButton.iconName
                rotation: iconRotate ? iconRotate : 0
            }
        }
    }
}
