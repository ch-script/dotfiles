import Quickshell
import QtQuick
import QtQuick.Effects
import "../../theme"

Rectangle {
    id: root

    property string logoName: "NixOS.svg"

    implicitWidth: Metrics.barHeight - 6
    implicitHeight: Metrics.barHeight - 6
    radius: Metrics.buttonRadius
    color: mouse.containsMouse ? Qt.alpha(Colors.foreground, 0.08) : "transparent"

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Image {
        id: logoImg
        anchors.fill: parent
        anchors.margins: 4
        fillMode: Image.PreserveAspectFit
        source: "../../assets/logos/" + root.logoName
        sourceSize.width: Metrics.barHeight * 2
        sourceSize.height: Metrics.barHeight * 2
        smooth: true
        asynchronous: true
        visible: false

        onStatusChanged: {
            if (status === Image.Error)
                console.warn("nologo", root.logoName)
        }
    }

    Rectangle {
        anchors.fill: logoImg
        color: Colors.accent
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: logoImg
            maskThresholdMin: 0.5
            maskSpreadAtMin: 0.5
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached([
            "rofi", "-show", "drun", "-theme",
            Quickshell.env("HOME") + "/.config/rofi/rofiConf.rasi"
        ])
    }
}
