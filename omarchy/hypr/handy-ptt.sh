#!/bin/sh
# Hold-to-talk bridge for Handy — called from ~/.config/hypr/bindings.lua.
# Handy's CLI only offers --toggle-transcription, so PTT is emulated: press
# starts, the first release stops. The flag file records "recording started",
# which makes every path idempotent, turns a stray ALT release (e.g. after
# ALT+W) into a no-op, and lets a missed release degrade to a press-again stop.
# Flags older than 120s are stale. If Handy isn't running, `start` only launches
# it — toggling during init panics its transcription coordinator.

flag="${XDG_RUNTIME_DIR:-/tmp}/handy-ptt.recording"
now=$(date +%s)

is_active() {
    [ -e "$flag" ] || return 1
    started=$(cat "$flag" 2>/dev/null || echo 0)
    [ $((now - started)) -lt 120 ]
}

handy_running() {
    pgrep -x handy >/dev/null 2>&1
}

case "$1" in
start)
    if ! handy_running; then
        # Cold start: only launch, never toggle during init (see header).
        setsid handy --start-hidden >/dev/null 2>&1 &
        exit 0
    fi
    if is_active; then
        # Press while the flag is set: a release was missed, so stop instead.
        rm -f "$flag"
        exec handy --toggle-transcription
    fi
    printf '%s\n' "$now" >"$flag"
    exec handy --toggle-transcription
    ;;
stop)
    handy_running || { rm -f "$flag"; exit 0; }   # app gone: just drop state
    is_active || exit 0
    rm -f "$flag"
    exec handy --toggle-transcription
    ;;
*)
    echo "usage: $0 start|stop" >&2
    exit 2
    ;;
esac
