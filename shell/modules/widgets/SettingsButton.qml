import Quickshell
import "../components"
import "../../theme"

IconButton {
    icon: "settings.svg"
    iconColor: Colors.accent
    onClicked: Quickshell.execDetached(["foot", "-e", "paw"])
}
