-- Personal input overrides. Keyboard mapping (Alt/Super swap + mac shortcuts)
-- is handled by keyd in /etc/keyd/default.conf — do NOT add an xkb swap here.

hl.config({
  input = {
    kb_layout = "us,pt",
    kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",

    sensitivity = 0.1,
    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.device({
  name = "pixart-usb-optical-mouse",
  sensitivity = -0.2,
})
