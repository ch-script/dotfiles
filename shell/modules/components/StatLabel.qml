import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../theme"

RowLayout {
    id: root

    property string icon: ""
    property string value: ""
    property color tint: Colors.foreground

    spacing: 6

    Item {
        Layout.preferredWidth: Metrics.iconSize
        Layout.preferredHeight: Metrics.iconSize

        Image {
            id: iconImg
            anchors.fill: parent
            source: root.icon ? "../../icons/" + root.icon : ""
            sourceSize.width: Metrics.iconSize * 2
            sourceSize.height: Metrics.iconSize * 2
            smooth: true
            visible: false

            onStatusChanged: {
                if (status === Image.Error)
                    console.warn("charging lead to error", root.icon)
            }
        }

        Rectangle {
            anchors.fill: iconImg
            color: root.tint
            //color: Colors.foreground
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: iconImg
                maskThresholdMin: 0.5
                maskSpreadAtMin: 0.5
            }
        }
    }

    Text {
        text: root.value
        color: Colors.foreground
        font.family: Metrics.textFont
        font.pixelSize: Metrics.clockFontSize
    }
}
