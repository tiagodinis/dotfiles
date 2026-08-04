-- Main Hyprland config. Omarchy defaults first, then personal overrides.
-- Docs: https://wiki.hypr.land/Configuring/Start/

dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Uncomment to drop Omarchy's default bindings, or just the preinstalled apps':
-- omarchy_default_bindings = false
-- omarchy_preinstalled_bindings = false
require("default.hypr.omarchy")

require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("default.hypr.toggles")

-- Keep Handy's recording overlay visible but never focusable, or the transcript
-- is typed into it instead of the focused app (see README.md).
o.window(
  { class = "Handy", title = "Recording" },
  { no_focus = true, suppress_event = "activate" }
)
