import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../theme"

PanelWindow {
    id: clockWidget

    required property var modelData
    screen: modelData

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "clock-widget"
    mask: Region {}

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        Item {
            id: avatarBox
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 160
            Layout.preferredHeight: 160

            Image {
                id: avatar
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/images/mizaki.jpg")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                visible: false
                layer.enabled: true
            }

            Item {
                id: avatarMask
                anchors.fill: parent
                visible: false
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    radius: 24
                    color: "black"
                }
            }

            MultiEffect {
                anchors.fill: parent
                source: avatar
                maskEnabled: true
                maskSource: avatarMask
            }
        }

        Text {
            id: timeLabel
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(clock.date, "hh:mm")
            color: Colors.foreground
            font.family: Metrics.textFont
            font.pixelSize: 120
            font.weight: Font.DemiBold
        }

        Text {
            id: dateLabel
            Layout.alignment: Qt.AlignHCenter
            text: {
                const s = Qt.formatDate(clock.date, "dddd d 'de' MMMM");
                return s.charAt(0).toUpperCase() + s.slice(1);
            }
            color: Colors.foreground
            font.family: Metrics.textFont
            font.pixelSize: 28
        }
    }
}
