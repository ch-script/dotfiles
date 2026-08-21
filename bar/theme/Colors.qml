pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// ~/.cache/wal/colors-quickshell.json
Singleton {
    id: root

    // Fallback
    readonly property var fallback: ({
        background: "#1e1e2e",
        foreground: "#cdd6f4",
        color0: "#1e1e2e",
        color1: "#f38ba8",
        color2: "#a6e3a1",
        color3: "#f9e2af",
        color4: "#89b4fa",
        color5: "#cba6f7",
        color6: "#94e2d5",
        color7: "#bac2de",
        color8: "#585b70",
        color15: "#ffffff"
    })

    property var palette: fallback

    readonly property color background: palette.background // should add more
    readonly property color foreground: palette.foreground
    readonly property color accent: palette.color4
    readonly property color danger: palette.color1
    readonly property color muted: palette.color8

    FileView {
        id: paletteFile
        path: Quickshell.env("HOME") + "/.cache/wal/colors-quickshell.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.palette = JSON.parse(text())
            } catch (e) {
                console.warn("Colors couldn't be parsed, using fallback", e)
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: paletteFile.reload()
    }
}
