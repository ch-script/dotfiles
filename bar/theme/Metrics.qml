pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // margin
    readonly property int barHeight: 28
    readonly property int barMarginTop: 5
    readonly property int barMarginSide: 10

    // hover backgroun
    readonly property real barBackgroundOpacity: 0.55
    readonly property int barRadius: 12

    // padin
    readonly property int buttonRadius: 8
    readonly property int buttonPadding: 6
    readonly property int groupSpacing: 4
    readonly property int sectionSpacing: 14

    //icons only
    readonly property string iconFont: "Symbols Nerd Font Mono"
    readonly property string textFont: "JetBrainsMono Nerd Font"
    readonly property int iconSize: 15
    readonly property int clockFontSize: 13

    readonly property int popupWidth: 340
    readonly property int popupGap: -30
    readonly property int popupPadding: 16
    readonly property int popupRadius: 16
}
