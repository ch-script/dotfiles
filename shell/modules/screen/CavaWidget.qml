import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../theme"

PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    property string position: "bottom"
    property real thickness: 200
    property real edgeMargin: 0
    property real sideMargin: 0

    property string style: "bars"
    property int barCount: 64
    property real barSpacing: 4
    property real barRadius: 3
    property color barColor: Colors.accent
    property real visualOpacity: 0.8
    property real smoothing: 0.5
    property real minBar: 2

    property string cavaConfig: Quickshell.env("HOME") + "/dotfiles/shell/assets/cava/quickshell.conf"

    property var levels: []

    readonly property bool horizontal: position === "bottom" || position === "top"

    anchors {
        left: position !== "right"
        right: position !== "left"
        top: position !== "bottom"
        bottom: position !== "top"
    }

    implicitHeight: horizontal ? thickness : 0
    implicitWidth: horizontal ? 0 : thickness

    margins {
        top: position === "top" ? edgeMargin : (horizontal ? 0 : sideMargin)
        bottom: position === "bottom" ? edgeMargin : (horizontal ? 0 : sideMargin)
        left: position === "left" ? edgeMargin : (horizontal ? sideMargin : 0)
        right: position === "right" ? edgeMargin : (horizontal ? sideMargin : 0)
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "cava-widget"
    mask: Region {}

    function resample(arr, n) {
        if (arr.length === n) return arr
        if (arr.length === 1) return Array(n).fill(arr[0])
        const out = []
        for (let i = 0; i < n; i++) {
            const t = n > 1 ? i * (arr.length - 1) / (n - 1) : 0
            const lo = Math.floor(t)
            const hi = Math.min(lo + 1, arr.length - 1)
            const f = t - lo
            out.push(arr[lo] * (1 - f) + arr[hi] * f)
        }
        return out
    }

    onLevelsChanged: if (style === "wave") wave.requestPaint()

    Item {
        id: viz
        anchors.fill: parent
        opacity: root.visualOpacity

        readonly property real span: root.horizontal ? width : height
        readonly property real depth: root.horizontal ? height : width

        // Style bars
        Repeater {
            model: root.style === "bars" ? root.barCount : 0

            delegate: Rectangle {
                required property int index

                readonly property real barSize:
                    (viz.span - root.barSpacing * (root.barCount - 1)) / root.barCount
                readonly property real len:
                    Math.max(root.minBar, (root.levels[index] || 0) * viz.depth)

                radius: root.barRadius
                color: root.barColor

                width: root.horizontal ? barSize : len
                height: root.horizontal ? len : barSize
                x: root.horizontal ? index * (barSize + root.barSpacing)
                                   : (root.position === "right" ? viz.depth - len : 0)
                y: root.horizontal ? (root.position === "bottom" ? viz.depth - len : 0)
                                   : index * (barSize + root.barSpacing)
            }
        }

        // Style wave
        Canvas {
            id: wave
            anchors.fill: parent
            visible: root.style === "wave"

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const n = root.levels.length
                if (root.style !== "wave" || n < 2) return

                const span = viz.span
                const depth = viz.depth
                const pos = root.position

                function P(a, h) {
                    if (pos === "bottom") return { x: a, y: depth - h }
                    if (pos === "top")    return { x: a, y: h }
                    if (pos === "left")   return { x: h, y: a }
                    return { x: depth - h, y: a }
                }

                const pts = []
                for (let i = 0; i < n; i++) {
                    const h = Math.max(root.minBar, (root.levels[i] || 0) * depth)
                    pts.push(P(i / (n - 1) * span, h))
                }

                ctx.beginPath()
                const b0 = P(0, 0)
                ctx.moveTo(b0.x, b0.y)
                ctx.lineTo(pts[0].x, pts[0].y)
                for (let i = 1; i < n - 1; i++) {
                    const mx = (pts[i].x + pts[i + 1].x) / 2
                    const my = (pts[i].y + pts[i + 1].y) / 2
                    ctx.quadraticCurveTo(pts[i].x, pts[i].y, mx, my)
                }
                ctx.lineTo(pts[n - 1].x, pts[n - 1].y)
                const b1 = P(span, 0)
                ctx.lineTo(b1.x, b1.y)
                ctx.closePath()

                const from = P(0, 0)
                const to = P(0, depth)
                const g = ctx.createLinearGradient(from.x, from.y, to.x, to.y)
                g.addColorStop(0, Qt.rgba(root.barColor.r, root.barColor.g, root.barColor.b, 1.0))
                g.addColorStop(1, Qt.rgba(root.barColor.r, root.barColor.g, root.barColor.b, 0.25))
                ctx.fillStyle = g
                ctx.fill()
            } // so far the only styles
        }
    }

    Process {
        id: cava
        running: true
        command: ["cava", "-p", root.cavaConfig]

        stdout: SplitParser {
            onRead: (line) => {
                if (!line) return
                const parts = line.trim().split(";").filter(s => s.length > 0)
                if (parts.length === 0) return

                const raw = parts.map(n => Math.min(1, parseInt(n) / 1000))
                const target = root.resample(raw, root.barCount)
                const prev = root.levels

                root.levels = target.map((v, i) => {
                    const p = prev[i] || 0
                    return v > p ? p + (v - p) * 0.7
                                 : p + (v - p) * (1 - root.smoothing)
                })
                watchdog.restart()
            }
        }

        onExited: (code, status) => restartTimer.start()
    }

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
