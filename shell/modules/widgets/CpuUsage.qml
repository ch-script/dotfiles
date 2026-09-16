import Quickshell.Io
import "../components"
import "../../theme"
import QtQuick

StatLabel {
    id: root
    icon: "cpu.svg"
    value: Math.round(usage) + "%"
    tint: Colors.accent

    property real usage: 0
    property real lastIdle: 0
    property real lastTotal: 0

    Process {
        id: statProc
        command: ["sh", "-c", "head -n1 /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/).slice(1).map(Number)
                const idle = parts[3] + parts[4]
                const total = parts.reduce((a, b) => a + b, 0)

                if (root.lastTotal > 0) {
                    const deltaIdle = idle - root.lastIdle
                    const deltaTotal = total - root.lastTotal
                    if (deltaTotal > 0) root.usage = 100 * (1 - deltaIdle / deltaTotal)
                }
                root.lastIdle = idle
                root.lastTotal = total
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statProc.running = true
    }
}
