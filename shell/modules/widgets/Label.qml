import QtQuick
import "../../theme"

Text {
    property alias value: root.text
    id: root

    color: Colors.foreground
    font.family: Metrics.textFont
    font.pixelSize: Metrics.clockFontSize
}
