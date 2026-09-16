import QtQuick
import Quickshell
import Quickshell.Io
import "../../theme"

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property string title: ""
    property bool playing: false

    function trunc(t) {
        return t.length > 28 ? t.substring(0, 28) + "…" : t
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.title.length > 0 ? root.trunc(root.title) : "Nothing playing"
        color: root.title.length > 0 && root.playing ? Colors.foreground : Colors.accent
        font.family: Metrics.textFont
        font.pixelSize: Metrics.clockFontSize
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["playerctl", "play-pause"])
    }

    Process {
        id: playerProc
        command: ["playerctl", "metadata", "--format", "{{title}}||{{status}}", "--follow"]
        stdout: SplitParser {
            onRead: (line) => {
                if (!line) { root.title = ""; return }
                const parts = line.split("||")
                if (parts.length < 2) return
                root.title = parts[0]
                root.playing = parts[1] === "Playing"
            }
        }
        onRunningChanged: {
            if (!running) restartTimer.start()
        }
        Component.onCompleted: running = true
    }

    Timer {
        id: restartTimer
        interval: 3000
        repeat: false
        onTriggered: playerProc.running = true
    }
}
