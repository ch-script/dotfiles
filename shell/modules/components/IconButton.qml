import QtQuick
import QtQuick.Effects
import "../../theme"

Rectangle {
    id: root

    property string icon: ""
    property color iconColor: Colors.foreground
    property bool active: false

    signal clicked()
    signal wheelUp()
    signal wheelDown()

    implicitWidth: Metrics.iconSize + Metrics.buttonPadding * 2
    implicitHeight: Metrics.barHeight - 6
    radius: Metrics.buttonRadius
    color: mouse.containsMouse ? Qt.alpha(Colors.foreground, 0.08) : "transparent"

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Image {
        id: iconImg
        anchors.centerIn: parent
        width: Metrics.iconSize
        height: Metrics.iconSize
        source: root.icon ? "../../icons/" + root.icon : ""
        sourceSize.width: Metrics.iconSize * 2
        sourceSize.height: Metrics.iconSize * 2
        smooth: true
        visible: false
    }

    Rectangle {
        anchors.fill: iconImg
        color: root.active ? Colors.accent : root.iconColor
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: iconImg
            maskThresholdMin: 0.5
            maskSpreadAtMin: 0.5
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onWheel: (event) => {
            if (event.angleDelta.y > 0) root.wheelUp()
            else if (event.angleDelta.y < 0) root.wheelDown()
        }
    }

}
