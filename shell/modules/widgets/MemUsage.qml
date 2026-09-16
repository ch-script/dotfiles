import Quickshell.Io
import "../components"
import "../../theme"
import QtQuick

StatLabel {
    id: root
    icon: "ram.svg"
    tint: Colors.accent
    value: Math.round(usage) + "%"

    property real usage: 0

    Process {
        id: memProc
        command: ["sh", "-c", "grep -E 'MemTotal|MemAvailable' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                let total = 0, available = 0
                for (const l of lines) {
                    const m = l.match(/(\d+)/)
                    if (!m) continue
                    if (l.startsWith("MemTotal")) total = parseInt(m[1])
                    else if (l.startsWith("MemAvailable")) available = parseInt(m[1])
                }
                if (total > 0) root.usage = 100 * (1 - available / total)
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProc.running = true
    }
}
