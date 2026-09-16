import QtQuick
import Quickshell.Io
import "../../theme"

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string dateText: ""

    Text {
        id: label
        anchors.centerIn: parent
        text: root.dateText
        color: Colors.foreground
        font.family: Metrics.textFont
        font.pixelSize: Metrics.clockFontSize
    }

    Process {
        id: dateProc
        command: ["date", "+%a %d %b"]
        stdout: StdioCollector {
            onStreamFinished: root.dateText = this.text.trim()
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dateProc.running = true
    }
}
