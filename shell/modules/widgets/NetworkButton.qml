import Quickshell
import "../components"
import "../../theme"

IconButton {
    icon: "wifi.svg"
    iconColor: Colors.accent
    onClicked: Quickshell.execDetached(["foot", "-e", "nmtui"])
}
