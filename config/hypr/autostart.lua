hl.on("hyprland.start", function ()
hl.exec_cmd("nm-applet")
hl.exec_cmd("hyprpaper")
hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
hl.exec_cmd("hypridle")

hl.exec_cmd(
    "quickshell -p /home/emo/Programs/HyprCade/config/quickshell/HyprCade"
)
end)
