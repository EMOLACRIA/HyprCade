local defaultTheme = {
    active_border = {
        "rgba(D33A3Aee)",
        "rgba(3977A8ee)",
    },

    inactive_border = "rgba(243644aa)",
}

local theme = defaultTheme

local home = os.getenv("HOME")

if home then
    local themePath =
    home .. "/.local/state/hyprcade/hypr-theme.lua"

    local ok, loaded = pcall(dofile, themePath)

    if ok and type(loaded) == "table" then
        theme = loaded
        end
        end

hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 2,

        border_size = 1,

        col = {
            active_border = {
                colors = theme.active_border,
                angle = 45,
            },

            inactive_border = theme.inactive_border,
        },

        resize_on_border = false,
        allow_tearing = false,

        layout = "dwindle",
    },
})


hl.config({
    decoration = {
        rounding = 0,
        rounding_power = 2,

        active_opacity = 1.0,
        inactive_opacity = 0.98,

        shadow = {
            enabled = false,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = false,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
})
