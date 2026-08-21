import Quickshell
import "../components"
import "../../theme"

IconButton {
    icon: "volume.svg"
    //onClicked: UiState.soundPopupOpen = !UiState.soundPopupOpen
    onClicked: Quickshell.execDetached(["pavucontrol"])
    onWheelUp: Quickshell.execDetached(["ch", "audio", "vol_up"])
    onWheelDown: Quickshell.execDetached(["ch", "audio", "vol_down"])
}