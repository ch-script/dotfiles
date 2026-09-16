import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../theme"

Item {
    id: root

    required property string screenName

    property var workspaces: []

    readonly property var onThisScreen: workspaces
        .filter(ws => ws.output === root.screenName)
        .sort((a, b) => a.idx - b.idx)

    implicitWidth: dotsRow.implicitWidth
    implicitHeight: Metrics.barHeight - 6

    RowLayout {
        id: dotsRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.onThisScreen
            delegate: Rectangle {
                id: dot
                required property var modelData
                width: modelData.is_active ? 10 : 7
                height: width
                radius: width / 2
                color: modelData.is_active ? Colors.accent : Qt.alpha(Colors.foreground, 0.35)

                Behavior on width { NumberAnimation { duration: 120 } }
                Behavior on color { ColorAnimation { duration: 120 } }
            }
        }
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: (line) => {
                if (!line) return
                let event
                try {
                    event = JSON.parse(line)
                } catch (e) {
                    return
                }

                if (event.WorkspacesChanged) {
                    root.workspaces = event.WorkspacesChanged.workspaces
                } else if (event.WorkspaceActivated) {
                    const id = event.WorkspaceActivated.id
                    const target = root.workspaces.find(ws => ws.id === id)
                    if (!target) return
                    root.workspaces = root.workspaces.map(ws =>
                        ws.output === target.output
                            ? Object.assign({}, ws, { is_active: ws.id === id })
                            : ws
                    )
                }
            }
        }
    }
}
