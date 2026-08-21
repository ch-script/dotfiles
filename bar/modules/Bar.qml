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
        spacing: Metrics.groupSpacing
        SearchButton {}
    }

    Clock {
        anchors.centerIn: parent
    }

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Metrics.groupSpacing


        BluetoothButton {}
        SoundButton {}
        BatteryIndicator {}
        SettingsButton {}
    }
}