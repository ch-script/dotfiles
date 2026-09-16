import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root

    default property alias content: innerRow.data

    property int padding: 8
    property real backgroundOpacity: 0.3
    property color tint: Colors.foreground

    property int cornerRadius: Metrics.buttonRadius
    property real heightRatio: 0.8

    radius: cornerRadius
    color: Qt.alpha(tint, backgroundOpacity)

    implicitWidth: innerRow.implicitWidth + padding * 2
    implicitHeight: Metrics.barHeight * heightRatio

    RowLayout {
        id: innerRow
        anchors.centerIn: parent
        spacing: Metrics.groupSpacing
    }
}
