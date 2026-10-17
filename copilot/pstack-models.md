# pstack models

pstack's skills stay available by name (`/poteto-mode`, `/tdd`, …), but nothing
auto-engages at session start: the plugin's SessionStart hook greps this file for
the exact line below and skips injecting its mandate when it finds it.

`/setup-pstack` writes per-role model rows here; keep the `session hook` line when
you re-run it, and answer "off" if it asks, or it flips back on.

session hook: off
