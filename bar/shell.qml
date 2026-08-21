import Quickshell
import "modules"
import "modules/popups"

Scope {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Variants {
        model: Quickshell.screens
        SoundPopup {}
    }
}