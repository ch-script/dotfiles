import QtQuick
import Quickshell.Io
import "../components"
import "../../theme"

StatLabel {
    id: root
    icon: "amd.svg"
    tint: Colors.accent
    value: Math.round(usage) + "%"

    property real usage: 0
    property color iconColor: Colors.accent

    Process {
        id: gpuProc
        command: ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const n = parseInt(this.text.trim())
                if (!isNaN(n)) root.usage = n
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gpuProc.running = true
    }
}
