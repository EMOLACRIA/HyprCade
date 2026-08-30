import Quickshell

import "Layers" as Common
import "Themes/EldenRing" as EldenRing
import "Themes/Evangelion" as Evangelion
import "Data"

Scope {
    Palette {
        id: colors
    }


    // ============================================================
    // TOP BAR
    // ============================================================

    LazyLoader {
        active: colors.themeId === "evangelion"

        Evangelion.TopBar {}
    }

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.TopBar {}
    }

    LazyLoader {
        active:
        colors.themeId !== "elden-ring"
        && colors.themeId !== "evangelion"

        Common.TopBar {}
    }


    // ============================================================
    // LAUNCHER
    // ============================================================

    LazyLoader {
        active: colors.themeId === "evangelion"

        Evangelion.Launcher {}
    }

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.Launcher {}
    }

    LazyLoader {
        active:
        colors.themeId !== "elden-ring"
        && colors.themeId !== "evangelion"

        Common.Launcher {}
    }


    // ============================================================
    // RIGHT PANEL
    // ============================================================

    LazyLoader {
        active: colors.themeId === "evangelion"

        Evangelion.RightPanel {}
    }

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.RightPanel {}
    }

    LazyLoader {
        active:
        colors.themeId !== "elden-ring"
        && colors.themeId !== "evangelion"

        Common.RightPanel {}
    }


    // ============================================================
    // CONTROL PANEL
    // ============================================================

    LazyLoader {
        active: colors.themeId === "evangelion"

        Evangelion.ControlPanel {}
    }

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.ControlPanel {}
    }

    LazyLoader {
        active:
        colors.themeId !== "elden-ring"
        && colors.themeId !== "evangelion"

        Common.ControlPanel {}
    }


    // ============================================================
    // POWER MENU
    // ============================================================

    LazyLoader {
        active: colors.themeId === "evangelion"

        Evangelion.PowerMenu {}
    }

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.PowerMenu {}
    }

    LazyLoader {
        active:
        colors.themeId !== "elden-ring"
        && colors.themeId !== "evangelion"

        Common.PowerMenu {}
    }


    // ============================================================
    // OSD
    // ============================================================

    LazyLoader {
        active: colors.themeId === "evangelion"

        Evangelion.Osd {}
    }

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.Osd {}
    }

    LazyLoader {
        active:
        colors.themeId !== "elden-ring"
        && colors.themeId !== "evangelion"

        Common.Osd {}
    }


    // ============================================================
    // VISUAL DECK
    // ============================================================

    LazyLoader {
        active: colors.themeId === "evangelion"

        Evangelion.VisualDeck {}
    }

    LazyLoader {
        active: colors.themeId === "elden-ring"

        EldenRing.VisualDeck {}
    }

    LazyLoader {
        active:
        colors.themeId !== "elden-ring"
        && colors.themeId !== "evangelion"

        Common.VisualDeck {}
    }
}
