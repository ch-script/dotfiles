import Quickshell.Io
import "../components"
import "../../theme"
import QtQuick


StatLabel {
    id: root
    icon: "nvidia.svg"
    tint: Colors.accent
    value: Math.round(usage) + "%"
    property color iconColor: Colors.accent

    property real usage: 0

    Process {
        id: gpuProc
        command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
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
