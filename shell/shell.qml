import Quickshell
import "theme"
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

    Variants {
        model: Quickshell.screens
        ClockWidget {
            anchorPoint: "left"
            offsetX: 0
            avatarSource: Qt.resolvedUrl("assets/images/adachirei.gif")
            avatarScale: 1
        }
    }

    Variants {
        model: Quickshell.screens
        CavaWidget {
            position: "bottom"
            thickness: 50
            style: "wave"
            barCount: 50
            smoothing: 0.2
            barColor: Colors.accent
            visualOpacity: 0.7
        }
    }
}
