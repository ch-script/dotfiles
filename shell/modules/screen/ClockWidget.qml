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

    // "center", "top", "bottom", "left", "right",
    // "top-left", "top-right", "bottom-left", "bottom-right"
    property string anchorPoint: "center"
    property real offsetX: 0
    property real offsetY: 0
    property real edgeMargin: 40

    property bool showAvatar: true
    property url avatarSource: Qt.resolvedUrl("../../assets/images/teto.jpg")
    property real avatarScale: 1.0
    property real avatarBaseSize: 160
    property real avatarBaseRadius: 24

    property bool showBackground: true
    property color tintColor: Colors.background
    property real tintOpacity: 0.35
    property real panelRadius: 32
    property real panelPadding: 32

    readonly property bool atLeft: anchorPoint.indexOf("left") !== -1
    readonly property bool atRight: anchorPoint.indexOf("right") !== -1
    readonly property bool atTop: anchorPoint.indexOf("top") !== -1
    readonly property bool atBottom: anchorPoint.indexOf("bottom") !== -1

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "clock-widget"
    mask: Region {}

    BackgroundEffect.blurRegion: Region {
        item: panelBackground
        radius: clockWidget.panelRadius
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Item {
        id: panel

        width: content.implicitWidth + clockWidget.panelPadding * 2
        height: content.implicitHeight + clockWidget.panelPadding * 2

        x: Math.round((clockWidget.atLeft ? clockWidget.edgeMargin
            : clockWidget.atRight ? clockWidget.width - width - clockWidget.edgeMargin
            : (clockWidget.width - width) / 2) + clockWidget.offsetX)

        y: Math.round((clockWidget.atTop ? clockWidget.edgeMargin
            : clockWidget.atBottom ? clockWidget.height - height - clockWidget.edgeMargin
            : (clockWidget.height - height) / 2) + clockWidget.offsetY)

        Rectangle {
            id: panelBackground
            anchors.fill: parent
            visible: clockWidget.showBackground
            radius: clockWidget.panelRadius
            color: Qt.alpha(clockWidget.tintColor, clockWidget.tintOpacity)
        }

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: 0

            Item {
                id: avatarBox
                visible: clockWidget.showAvatar
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: clockWidget.avatarBaseSize * clockWidget.avatarScale
                Layout.preferredHeight: clockWidget.avatarBaseSize * clockWidget.avatarScale

                AnimatedImage {
                    id: avatar
                    anchors.fill: parent
                    source: clockWidget.avatarSource
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                    playing: true
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
                        radius: clockWidget.avatarBaseRadius * clockWidget.avatarScale
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
}
