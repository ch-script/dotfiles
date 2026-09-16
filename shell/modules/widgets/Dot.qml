import QtQuick
import "../../theme"

Rectangle {
    property int size: 4
    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: Colors.accent
}
