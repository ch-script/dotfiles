import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../components"

PanelWindow { // WIP
    id: popup
    required property var modelData
    screen: modelData

    visible: UiState.soundPopupOpen

    anchors {
        top: true
        right: true
    }

    margins.top: Metrics.barHeight + Metrics.barMarginTop + Metrics.popupGap
    margins.right: Metrics.barMarginSide

    implicitWidth: Metrics.popupWidth
    implicitHeight: content.implicitHeight + Metrics.popupPadding * 2

    exclusiveZone: 0
    color: "transparent"

    property var nowPlaying: ({
        title: "Reproducing",
        progress: 0.35
    })
    property var appVolumes: [
        { volume: 0.7 },
        { volume: 0.45 },
        { volume: 0.9 }
    ]

    Rectangle {
        id: popupBackground
        anchors.fill: parent
        radius: Metrics.popupRadius
        color: Qt.alpha(Colors.background, Metrics.barBackgroundOpacity)
    }

    BackgroundEffect.blurRegion: Region {
        item: popupBackground
        radius: Metrics.popupRadius
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Metrics.popupPadding
        spacing: 14
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Rectangle {
                width: 76
                height: 76
                radius: width / 2
                color: Colors.muted
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: popup.nowPlaying.title
                    color: Colors.foreground
                    font.family: Metrics.textFont
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }

                RowLayout {
                    spacing: 4
                    IconButton { icon: "player-skip-back.svg" }
                    IconButton { icon: "player-play.svg" }
                    IconButton { icon: "player-skip-forward.svg" }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 3
                    radius: 2
                    color: Qt.alpha(Colors.foreground, 0.15)

                    Rectangle {
                        width: parent.width * popup.nowPlaying.progress
                        height: parent.height
                        radius: parent.radius
                        color: Colors.accent
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.alpha(Colors.foreground, 0.12)
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: popup.appVolumes
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        width: 32
                        height: 32
                        radius: width / 2
                        color: Colors.muted

                        Text {
                            anchors.centerIn: parent
                            text: "App"
                            font.pixelSize: 9
                            color: Colors.foreground
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 2
                        color: Qt.alpha(Colors.foreground, 0.15)

                        Rectangle {
                            width: parent.width * modelData.volume
                            height: parent.height
                            radius: parent.radius
                            color: Colors.foreground
                        }
                    }
                }
            }
        }
    }
}