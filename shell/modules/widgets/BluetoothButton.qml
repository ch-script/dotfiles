import Quickshell
import "../components"
import "../../theme"
IconButton {
    icon: "bluetooth.svg"
    iconColor: Colors.accent
    onClicked: Quickshell.execDetached(["blueman-manager"])
}
