import Quickshell

import "Layers" as Common
import "Themes/EldenRing" as EldenRing
import "Data"

Scope {
    Palette {
        id: colors
    }


    // ============================================================
    // TOP BAR
    // ============================================================

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.TopBar {}
    }

    LazyLoader {
        active: colors.themeId !== "elden-ring"

        Common.TopBar {}
    }


    // ============================================================
    // LAUNCHER
    // ============================================================

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.Launcher {}
    }

    LazyLoader {
        active: colors.themeId !== "elden-ring"

        Common.Launcher {}
    }


    // ============================================================
    // RIGHT PANEL
    // ============================================================

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.RightPanel {}
    }

    LazyLoader {
        active: colors.themeId !== "elden-ring"

        Common.RightPanel {}
    }


    // ============================================================
    // CONTROL PANEL
    // ============================================================

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.ControlPanel {}
    }

    LazyLoader {
        active: colors.themeId !== "elden-ring"

        Common.ControlPanel {}
    }


    // ============================================================
    // POWER MENU
    // ============================================================

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.PowerMenu {}
    }

    LazyLoader {
        active: colors.themeId !== "elden-ring"

        Common.PowerMenu {}
    }


    // ============================================================
    // OSD
    // ============================================================

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.Osd {}
    }

    LazyLoader {
        active: colors.themeId !== "elden-ring"

        Common.Osd {}
    }


    // ============================================================
    // SHARED FOR NOW
    // ============================================================

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.VisualDeck {}
    }

    LazyLoader {
        active: colors.themeId !== "elden-ring"

        Common.VisualDeck {}
    }
}
