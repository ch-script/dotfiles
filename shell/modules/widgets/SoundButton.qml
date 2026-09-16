import Quickshell
import "../components"
import "../../theme"

IconButton {
    icon: "volume.svg"
    iconColor: Colors.accent
    //onClicked: UiState.soundPopupOpen = !UiState.soundPopupOpen
    onClicked: Quickshell.execDetached(["pavucontrol"])
    onWheelUp: Quickshell.execDetached(["paw", "audio", "vol_up"])
    onWheelDown: Quickshell.execDetached(["paw", "audio", "vol_down"])
}
