import Quickshell
import "modules"
import "modules/popups"
import "modules/screen"

Scope {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Variants {
        model: Quickshell.screens
        SoundPopup {}
    }

    Variants {
        model: Quickshell.screens
        WallpaperSelector {}
    }
}
