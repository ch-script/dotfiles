import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "widgets"

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Metrics.barHeight
    margins.top: Metrics.barMarginTop
    margins.left: Metrics.barMarginSide
    margins.right: Metrics.barMarginSide
    color: "transparent"
    exclusiveZone: implicitHeight + Metrics.barMarginTop

    Rectangle {
        id: barBackground
        anchors.fill: parent
        radius: Metrics.barRadius
        color: Qt.alpha(Colors.background, Metrics.barBackgroundOpacity)
    }

    BackgroundEffect.blurRegion: Region {
        item: barBackground
        radius: Metrics.barRadius
    }

    RowLayout {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Metrics.sectionSpacing

        Spacer { size: 0 }
        SearchButton {}
        Separator {}
        WorkspaceIndicator { screenName: bar.screen.name }
        Separator {}
        NowPlaying {}
        Separator {}
        CavaVisualizer { }
        Separator {}
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: Metrics.groupSpacing

        Container {
            backgroundOpacity: 0.1
            tint: Colors.accent
            padding: 12

            Clock {}
            Spacer { size: 3 }
            Dot {}
            Spacer { size: 3 }
            Date {}
        }
    }

    //Clock {
      //  anchors.centerIn: parent
      //}

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Metrics.groupSpacing

        Label { text: "Puru Puru Pururin" }
        Spacer { size: 6 }
        Separator {}
        Spacer { size: 6 }
        CpuUsage {}
        Spacer { size: 6 }
        Separator {}
        Spacer { size: 6 }
        GpuNVIDIA {}
        Spacer { size: 6 }
        Separator {}
        Spacer { size: 6 }
        MemUsage {}
        Spacer { size: 6 }
        Separator {}
        Container {
            backgroundOpacity: 0.1
            tint: Colors.accent
            padding: 12

            BluetoothButton {}
            SoundButton {}
            NetworkButton {}
            //BatteryIndicator {}
            SettingsButton {}

        }
        Spacer { size: 0 }
    }
}
