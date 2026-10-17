-- Personal environment overrides, loaded after Omarchy's defaults.
--
-- Prepend ~/.config/omarchy/bin so user wrappers shadow the system binaries
-- they are named after -- e.g. ttfx, which pins the screensaver effect.
-- Mirrors $OMARCHY_PATH/default/hypr/envs.lua: keep Omarchy's bin, drop
-- duplicates, then put the personal bin in front.

local home = os.getenv("HOME")
local omarchy_bin = (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/bin"
local user_bin = home .. "/.config/omarchy/bin"

local kept = {}
for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin"):gmatch("[^:]+") do
  if entry ~= user_bin and entry ~= omarchy_bin then
    table.insert(kept, entry)
  end
end

table.insert(kept, 1, omarchy_bin)
table.insert(kept, 1, user_bin)

hl.env("PATH", table.concat(kept, ":"))
