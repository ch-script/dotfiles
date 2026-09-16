pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool open: false
    property bool loading: false
    property string currentPath: ""

    property ListModel wallpapers: ListModel {}

    function show() {
        root.refresh();
        root.open = true;
    }

    function hide() {
        root.open = false;
    }

    function toggle() {
        if (root.open)
            root.hide();
        else
            root.show();
    }

    function refresh() {
        if (listProc.running)
            return;
        root.wallpapers.clear();
        root.loading = true;
        listProc.running = true;
    }

    function apply(path) {
        root.currentPath = path;
        applyProc.command = ["wallpaper-apply", path];
        applyProc.running = true;
        root.hide();
    }

    Process {
        id: listProc
        command: ["wallpaper-list"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                if (!line || line.length === 0)
                    return;
                const parts = line.split("\t");
                if (parts.length < 4)
                    return;
                root.wallpapers.append({
                    name: parts[0],
                    path: parts[1],
                    thumb: parts[2],
                    kind: parts[3]
                });
            }
        }

        onExited: root.loading = false
    }

    Process {
        id: applyProc
        command: ["wallpaper-apply"]
    }

    FileView {
        id: stateFile
        path: `${Quickshell.env("HOME")}/.local/state/wallpaper-select/current`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const lines = stateFile.text().split("\n");
            if (lines.length > 1)
                root.currentPath = lines[1].trim();
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.show();
        }
        function close(): void {
            root.hide();
        }
        function refresh(): void {
            root.refresh();
        }
    }
}
