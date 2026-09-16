import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../theme"

PanelWindow {
    id: selector

    required property var modelData
    screen: modelData

    readonly property color bg: Colors.background
    readonly property color fg: Colors.foreground
    readonly property color accent: Colors.accent

    readonly property int panelWidth: 250
    readonly property int panelRadius: 16
    readonly property int cardRadius: 10
    readonly property int gutter: 10

    visible: selector.showPanel
    property bool showPanel: false

    Connections {
        target: WallpaperState
        function onOpenChanged() {
            if (WallpaperState.open)
                selector.showPanel = true;
        }
    }

    NumberAnimation {
        id: slideAnim
        target: slideRoot
        property: "x"
        duration: 180
        onFinished: {
            if (!WallpaperState.open)
                selector.showPanel = false;
        }
    }

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: Metrics.barHeight + Metrics.barMarginTop + 8
        right: Metrics.barMarginSide
        bottom: 12
    }

    implicitWidth: panelWidth
    color: "transparent"
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WallpaperState.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Item {
        id: slideRoot
        anchors.fill: parent
        x: selector.panelWidth + 40
        opacity: 0

        states: State {
            name: "shown"
            when: WallpaperState.open

            PropertyChanges {
                target: slideRoot
                x: 0
                opacity: 1
            }
        }

        transitions: [
            Transition {
                from: ""
                to: "shown"
                NumberAnimation {
                    properties: "x,opacity"
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            },
            Transition {
                from: "shown"
                to: ""
                SequentialAnimation {
                    NumberAnimation {
                        properties: "x,opacity"
                        duration: 180
                        easing.type: Easing.InCubic
                    }
                    ScriptAction {
                        script: selector.showPanel = false
                    }
                }
            }
        ]

        Rectangle {
            id: panelBackground
            anchors.fill: parent
            radius: selector.panelRadius
            color: Qt.alpha(selector.bg, 0.55)
            border.width: 1
            border.color: Qt.alpha(selector.accent, 0.35)
        }

        FocusScope {
            anchors.fill: parent
            focus: WallpaperState.open

            Keys.onEscapePressed: WallpaperState.hide()
            Keys.onPressed: event => {
                if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) {
                    WallpaperState.refresh();
                    event.accepted = true;
                }
            }

            Text {
                id: header
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 14
                horizontalAlignment: Text.AlignHCenter
                text: WallpaperState.loading ? "Generating thumbnails" : "nyapaper"
                color: selector.accent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
            }

            Rectangle {
                id: headerRule
                anchors.top: header.bottom
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: selector.gutter
                anchors.rightMargin: selector.gutter
                height: 1
                color: Qt.alpha(selector.accent, 0.25)
            }

            ListView {
                id: list
                anchors.top: headerRule.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: selector.gutter
                anchors.bottomMargin: selector.gutter
                anchors.leftMargin: selector.gutter
                anchors.rightMargin: selector.gutter

                clip: true
                spacing: 12
                model: WallpaperState.wallpapers
                currentIndex: -1
                cacheBuffer: 600
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    id: bar
                    policy: ScrollBar.AsNeeded
                    width: 5

                    contentItem: Rectangle {
                        implicitWidth: 5
                        radius: 3
                        color: Qt.alpha(selector.accent, bar.pressed ? 0.9 : 0.6)
                    }
                    background: Rectangle {
                        implicitWidth: 5
                        radius: 3
                        color: Qt.alpha(selector.fg, 0.1)
                    }
                }

                delegate: Item {
                    id: card

                    required property int index
                    required property string name
                    required property string path
                    required property string thumb
                    required property string kind

                    readonly property bool active: WallpaperState.currentPath === card.path
                    readonly property string label: card.name.replace(/\.[^.]+$/, "")

                    width: list.width
                    height: thumbBox.height + caption.height + 6

                    Item {
                        id: thumbBox
                        width: parent.width
                        height: Math.round(width * 0.56)

                        Rectangle {
                            anchors.fill: parent
                            radius: selector.cardRadius
                            color: Qt.alpha(selector.fg, 0.06)
                        }

                        Image {
                            id: thumbImage
                            anchors.fill: parent
                            source: "file://" + card.thumb
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            sourceSize.width: 320
                            smooth: true
                            visible: false
                            layer.enabled: true
                        }

                        Item {
                            id: thumbMask
                            anchors.fill: parent
                            visible: false
                            layer.enabled: true

                            Rectangle {
                                anchors.fill: parent
                                radius: selector.cardRadius
                                color: "black"
                            }
                        }

                        MultiEffect {
                            anchors.fill: parent
                            source: thumbImage
                            maskEnabled: true
                            maskSource: thumbMask
                            opacity: thumbImage.status === Image.Ready ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 180
                                }
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: selector.cardRadius
                            color: "transparent"
                            border.width: card.active || hover.hovered ? 2 : 1
                            border.color: card.active ? selector.accent : Qt.alpha(selector.fg, hover.hovered ? 0.45 : 0.15)

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }
                        }

                        Rectangle {
                            visible: card.kind === "video"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 5
                            width: 18
                            height: 18
                            radius: 9
                            color: Qt.alpha(selector.bg, 0.7)

                            Text {
                                anchors.centerIn: parent
                                text: "\u25B6"
                                color: selector.fg
                                font.pixelSize: 8
                            }
                        }
                    }

                    Text {
                        id: caption
                        anchors.top: thumbBox.bottom
                        anchors.topMargin: 6
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: card.label
                        color: card.active ? selector.accent : Qt.alpha(selector.fg, 0.85)
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }

                    HoverHandler {
                        id: hover
                    }

                    TapHandler {
                        onTapped: WallpaperState.apply(card.path)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0 && !WallpaperState.loading
                    text: "No wallpapers on \n~/Pictures/Wallpapers"
                    horizontalAlignment: Text.AlignHCenter
                    color: Qt.alpha(selector.fg, 0.6)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }
            }
        }
    }

   // BackgroundEffect.blurRegion: Region {
     //   item: panelBackground
       // radius: selector.panelRadius
  //  }
}
