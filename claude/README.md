# Claude Code Config

## Expert Committee

Five experts available via `@tag` (one response) or `/command` (full session persona).

| Expert | Invocation | Focus |
|---|---|---|
| Architect | `@architect` / `/architect` | System design, tradeoffs, long-term maintainability |
| Product Manager | `@pm` / `/pm` | User value, scope, prioritization, MVP vs. vision |
| Code Reviewer | `@reviewer` / `/reviewer` | Correctness, readability, edge cases, performance |
| Security | `@security` / `/security` | OWASP, auth, data exposure, supply chain |
| UX Designer | `@ux` / `/ux` | Accessibility, interaction patterns, visual hierarchy |

### Usage patterns

```
# Quick tag — one response from that voice
@architect - should audio preloading live in a service worker or the component?

# Roundtable — multiple perspectives in one response
@pm @architect - is offline mode worth v1 scope?

# Deep load — become that expert for the rest of the session
/architect

# Full committee planning
@pm @architect @ux - help me scope a search-by-mood feature
```

### Files

- `CLAUDE.md` — committee definition, auto-loaded by Claude on every session
- `commands/architect.md` — deep-load prompt for architect persona
- `commands/pm.md` — deep-load prompt for PM persona
- `commands/reviewer.md` — deep-load prompt for reviewer persona
- `commands/security.md` — deep-load prompt for security persona
- `commands/ux.md` — deep-load prompt for UX persona

### Skill vs. Expert

- **Skill** = a recipe. Runs a process (start → steps → end). Invoked with `/skill-name`.
- **Expert** = a colleague. Holds a perspective that colors every response. Tagged with `@name` or loaded with `/command`.

### Adding a new expert

1. Add a `## @name` block to `CLAUDE.md` (for @tagging)
2. Create `commands/name.md` with a persona prompt (for `/name` deep-load)
