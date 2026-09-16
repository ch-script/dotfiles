import Quickshell
import "../components"
import "../../theme"

IconButton {
    icon: "battery.svg"
    iconColor: Colors.accent
    // To do (and test)
    onClicked: Quickshell.execDetached(["foot","ch battery battery_percent"])
}
