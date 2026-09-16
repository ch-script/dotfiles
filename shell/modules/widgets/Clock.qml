import QtQuick
import Quickshell.Io
import "../../theme"

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string timeText: ""

    Text {
        id: label
        anchors.centerIn: parent
        text: root.timeText
        color: Colors.foreground
        font.family: Metrics.textFont
        font.pixelSize: Metrics.clockFontSize
    }

    Process {
        id: dateProc
        command: ["date", "+%H:%M"]
        stdout: StdioCollector {
            onStreamFinished: root.timeText = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dateProc.running = true
    }
}
