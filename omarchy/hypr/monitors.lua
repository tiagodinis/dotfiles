-- Monitor layout. List monitors/modes: hyprctl monitors all
local scale = 1

hl.env("GDK_SCALE", tostring(scale))
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@100", position = "0x0", scale = scale })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto-right", scale = scale })

-- Workspaces 1-3 on the external display, 4-6 on the laptop panel.
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "4", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "5", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "6", monitor = "eDP-1" })