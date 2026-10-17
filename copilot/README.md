# Copilot Custom Agents & Skills

Source of truth for personal GitHub Copilot agents and skills, synced to the user profile (`~/.copilot/`) by the dotfiles save/restore scripts.

## Layout

```
copilot/
├── agents/                          → ~/.copilot/agents/         (user-level custom agents)
│   ├── implementer.agent.md            implements prompts; hands off URL; lands on approval
│   ├── merge-reconciler.agent.md       reconciles a branch after another merged first; lands approved work
│   ├── product-manager.agent.md        frames product problems, scope and trade-offs
│   └── project-manager.agent.md        plans delivery, dependencies, risk and commitments
├── skills/                          → ~/.copilot/skills/         (one <name>/ dir per skill; empty today)
├── pstack-models.md                 → ~/.copilot/pstack-models.md  pstack model sheet + hook switch
└── templates/                       (not synced) — GitHub-side files
    └── pull-request.md                 copy into a repo's .github/
```

- **Agents** = interactive personas (coding partner, reviewer, product and project managers).
- **Skills** = on-demand domain content (roadmaps, quizzes, procedures) that agents load.
  None are checked in right now; `copilot_restore` still creates `~/.copilot/skills/`, so adding a
  `<name>/SKILL.md` here is all a new one takes. An empty directory is not tracked by git.
- The folder name of a skill must match the `name` in its `SKILL.md` (lowercase + hyphens).
- **`pstack-models.md`** is [pstack](https://github.com/cursor/plugins/tree/main/pstack)'s model sheet,
  which its plugin reads from `~/.copilot/pstack-models.md`. The plugin's SessionStart hook greps that
  file for a line reading exactly `session hook: off`; our copy carries it, so pstack runs only when
  asked for by name instead of auto-engaging at session start. `/setup-pstack` also writes here — keep
  the switch line when you re-run it. Copied only when the repo has the file, so a machine that never
  ran `setup-pstack` keeps whatever is already live.
- **Templates** = neither. GitHub-side files (a PR template is read by GitHub from a repo's
  `.github/`), kept here only so there is one canonical copy. Unlike the entries above,
  `templates/` is **not** synced to `~/.copilot/`. To apply a template, copy it into the target
  repo as `.github/pull_request_template.md` —
  the source filename is deliberately not the GitHub one, since it is not a drop-in file here.

## Using the agents

`implementer` does the hands-on work: prompt it with a change and it implements, validates, and closes every turn with a short handoff — what was implemented, the running URL when one applies (left running for your manual check), and the few things to test by hand. Say *"all good"* once you've verified, and it lands the work — rebase onto the base branch, one squashed commit, green checks, merge. The *All good — merge it* handoff button runs the same landing through `merge-reconciler`.

`product-manager` challenges product decisions: problem framing, user and non-user, trade-offs, measurable success, and the smallest useful test. Start with `critique:` for its structured adversarial review.

`project-manager` works backwards from commitments to sequence delivery, expose dependencies and risk, and identify what must be cut when a plan does not fit. Start with `critique:` for its structured plan review.

`merge-reconciler` is invoked on a feature branch whose base has moved ahead — say `main` after a different feature merged. It reports what landed on the base, surfaces textual and semantic conflicts, proposes resolutions, applies only what you approve, then runs the repo's checks to prove both the merged-in feature and this branch still work. With approval — the *All good — merge it* handoff after an implementer run, or an explicit *"rebase with main, squash and merge a single commit"* — it enters *Landing mode* and skips the recon-and-wait loop: rebase, squash to one commit, checks, merge.

