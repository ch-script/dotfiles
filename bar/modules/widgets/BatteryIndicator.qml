import Quickshell
import "../components"

IconButton {
    icon: "battery.svg"
    // To do (and test)
    onClicked: Quickshell.execDetached(["foot","ch battery battery_percent"])
}