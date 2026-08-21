import Quickshell
import "../components"

IconButton {
    icon: "settings.svg"
    onClicked: Quickshell.execDetached(["foot","ch"])
}