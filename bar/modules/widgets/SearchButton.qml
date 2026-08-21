import Quickshell
import "../components"

IconButton {
    icon: "search.svg"
    onClicked: Quickshell.execDetached(["rofi", "-show", "drun", "-theme", Quickshell.env("HOME") + "/.config/rofi/rofiConf.rasi"])
}