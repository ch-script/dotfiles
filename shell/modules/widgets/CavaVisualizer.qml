import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

Item {
    id: root

    property int barCount: 18
    property real barWidth: 3
    property real barSpacing: 2
    property color barColor: Colors.accent

    property var levels: []

    implicitWidth: barCount * (barWidth + barSpacing) - barSpacing
    implicitHeight: Metrics.barHeight - 8

    RowLayout {
        anchors.fill: parent
        spacing: root.barSpacing

        Repeater {
            model: root.barCount
            delegate: Rectangle {
                required property int index
                Layout.preferredWidth: root.barWidth
                Layout.preferredHeight: Math.max(2, (root.levels[index] || 0) * root.implicitHeight)
                Layout.alignment: Qt.AlignBottom
                radius: root.barWidth / 2
                color: root.barColor

                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 60 }
                }
            }
        }
    }

    Process {
        id: cava
        running: true
        command: ["cava", "-p", Quickshell.env("HOME") + "/dotfiles/shell/assets/cava/quickshell.conf"]

        stdout: SplitParser {
            onRead: (line) => {
                if (!line) return
                const parts = line.trim().split(";").filter(s => s.length > 0)
                if (parts.length === 0) return
                root.levels = parts.map(n => Math.min(1, parseInt(n) / 1000))
                watchdog.restart()
            }
        }

        onExited: (code, status) => restartTimer.start()
    }
    //this helps if cava process ends somehow
    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: cava.running = true
    }

    Timer {
        id: watchdog
        interval: 5000
        running: true
        repeat: false
        onTriggered: {
            cava.running = false
            restartTimer.start()
        }
    }
}
