import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow { // WIP
    id: desktopClock
    required property var modelData
    screen: modelData
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell-desktop-clock"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusiveZone: 0
    color: "transparent"
    mask: Region {}

    property string timeText: ""
    property real posX: 0
    property real posY: 0

    Component.onCompleted: {
        const margin = 160
        const usableW = Math.max(width - margin * 2 - clockLabel.implicitWidth, 1)
        const usableH = Math.max(height - margin * 2 - clockLabel.implicitHeight, 1)
        posX = margin + Math.random() * usableW
        posY = margin + Math.random() * usableH
    }
    
    Text {
        id: clockLabel
        x: desktopClock.posX
        y: desktopClock.posY
        text: desktopClock.timeText
        color: Qt.alpha(Colors.foreground, 1)
        font.family: Metrics.textFont
        font.pixelSize: 150
        font.weight: Font.DemiBold
    }

    Process {
        id: timeProc
        command: ["date", "+%H:%M"]
        stdout: StdioCollector {
            onStreamFinished: desktopClock.timeText = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: timeProc.running = true
    }
}