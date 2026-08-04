-- Personal Hyprland overrides. Loaded after Omarchy's defaults, so a binding
-- that already exists must be released with hl.unbind() before it is re-bound.
-- Rationale: ../README.md

-- ── Free SUPER combos for apps ──────────────────────────────────────────────
-- Hyprland consumes a combo before the focused app sees it, so these Omarchy
-- defaults are unbound and the combo now reaches VS Code / Obsidian instead.
hl.unbind("F2")                  -- voxtype dictation    -> Obsidian rename
hl.unbind("F9")                  -- voxtype push-to-talk -> VS Code toggle breakpoint
hl.unbind("SUPER + J")           -- toggle split         -> VS Code meta+j
hl.unbind("SUPER + K")           -- keybindings sheet    -> VS Code meta+k
hl.unbind("SUPER + L")           -- workspace layout     -> (free)
hl.unbind("SUPER + P")           -- pseudo window        -> VS Code meta+p (quick open)
hl.unbind("SUPER + SHIFT + P")   -- Google Photos        -> VS Code shift+meta+p (palette)
hl.unbind("SUPER + S")           -- scratchpad           -> VS Code meta+s (save); ALT+S still moves it
hl.unbind("SUPER + SHIFT + B")   -- browser              -> VS Code shift+meta+b (aux bar)
hl.unbind("SUPER + SHIFT + D")   -- Docker webapp        -> Obsidian file explorer
hl.unbind("SUPER + SHIFT + E")   -- Hey/email            -> Obsidian emoji picker
hl.unbind("SUPER + SHIFT + G")   -- Signal webapp        -> Obsidian bookmarks
hl.unbind("SUPER + SHIFT + F")   -- file manager         -> removed
hl.unbind("SUPER + SHIFT + M")   -- Music                -> VS Code shift+meta+m (maximize aux bar)
hl.unbind("SUPER + SHIFT + N")   -- editor launcher      -> Obsidian new note to the right
hl.unbind("SUPER + SHIFT + O")   -- Obsidian launcher    -> VS Code shift+meta+o
hl.unbind("SUPER + SHIFT + X")   -- X webapp             -> VS Code shift+meta+x (extensions)
hl.unbind("SUPER + BACKSPACE")   -- window transparency  -> Obsidian delete file
hl.unbind("SUPER + comma")       -- dismiss notification -> Obsidian toggle left sidebar
hl.unbind("SUPER + SLASH")       -- monitor scale up     -> VS Code meta+/ (toggle comment)
hl.unbind("SUPER + ALT + SLASH") -- monitor scale down   -> VS Code meta+/
hl.unbind("SUPER + CTRL + L")    -- system lock          -> VS Code ctrl+k ctrl+meta+l
hl.unbind("SUPER + CTRL + R")    -- set reminder         -> keyd SUPER+R -> Ctrl+R swallows it

-- ── Launchers (moved SUPER -> ALT) ──────────────────────────────────────────
hl.unbind("SUPER + RETURN")
o.bind("ALT + RETURN", "Terminal", { omarchy = "terminal" })
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("ALT + SHIFT + RETURN", "Browser", { omarchy = "browser" })

-- ── Emoji picker ────────────────────────────────────────────────────────────
hl.unbind("SUPER + CTRL + E")
hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + SPACE", "Emojis", "omarchy-shell shell toggle omarchy.emojis")

-- ── Windows (moved SUPER -> ALT) ────────────────────────────────────────────
hl.unbind("SUPER + F")
o.bind("ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.unbind("SUPER + T")
o.bind("ALT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
hl.unbind("SUPER + O")
o.bind("ALT + O", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")
hl.unbind("SUPER + W")
o.bind("ALT + W", "Close window", hl.dsp.window.close())

-- Resize with [ / ] (code:20/21).
hl.unbind("SUPER + code:20")
o.bind("ALT + code:20", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.unbind("SUPER + code:21")
o.bind("ALT + code:21", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.unbind("SUPER + SHIFT + code:20")
o.bind("ALT + SHIFT + code:20", "Shrink window up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.unbind("SUPER + SHIFT + code:21")
o.bind("ALT + SHIFT + code:21", "Expand window down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- ── Dictation: Handy hold-to-talk ───────────────────────────────────────────
-- Handy's X11 global shortcut can't register under Hyprland, so drive it from
-- the WM: ALT+Q press starts, the first release stops. ALT = the physical Meta
-- key (keyd). All paths go through handy-ptt.sh, whose flag file makes them
-- idempotent and turns a missed release into a press-again stop.
o.bind("ALT + Q", "Dictation (Handy) hold to talk", "~/.config/hypr/handy-ptt.sh start")
o.bind("ALT + Q", nil, "~/.config/hypr/handy-ptt.sh stop", { release = true })
o.bind("ALT + ALT_L", nil, "~/.config/hypr/handy-ptt.sh stop", { release = true, ignore_mods = true })

-- ── Focus & swap (moved SUPER -> ALT) ───────────────────────────────────────
hl.unbind("SUPER + LEFT")
o.bind("ALT + LEFT", "Focus on left window", hl.dsp.focus({ direction = "l" }))
hl.unbind("SUPER + RIGHT")
o.bind("ALT + RIGHT", "Focus on right window", hl.dsp.focus({ direction = "r" }))
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")

hl.unbind("SUPER + SHIFT + LEFT")
o.bind("ALT + SHIFT + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
hl.unbind("SUPER + SHIFT + RIGHT")
o.bind("ALT + SHIFT + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
hl.unbind("SUPER + SHIFT + UP")
o.bind("ALT + SHIFT + UP", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
hl.unbind("SUPER + SHIFT + DOWN")
o.bind("ALT + SHIFT + DOWN", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- ── Tab ─────────────────────────────────────────────────────────────────────
-- ALT+Tab cycles windows in the current workspace; SUPER+Tab stays free so keyd
-- can send Ctrl+Tab to apps.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")
o.bind("ALT + TAB", "Cycle next window", hl.dsp.window.cycle_next())
o.bind("ALT + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))

