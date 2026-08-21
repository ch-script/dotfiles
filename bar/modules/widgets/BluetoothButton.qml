import Quickshell
import "../components"

IconButton {
    icon: "bluetooth.svg"
    onClicked: Quickshell.execDetached(["blueman-manager"])
}