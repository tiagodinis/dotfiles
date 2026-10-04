# Copilot Custom Agents & Skills

Source of truth for personal GitHub Copilot agents and skills, synced to the user profile (`~/.copilot/`) by the dotfiles save/restore scripts.

## Layout

```
copilot/
├── agents/                          → ~/.copilot/agents/         (user-level custom agents)
│   ├── meta-agent-reviewer.agent.md    audits agent/skill quality
│   ├── tutor.agent.md                  Socratic tutor (behavior only; loads skills)
│   └── merge-reconciler.agent.md       reconciles a branch after another merged first
├── skills/                          → ~/.copilot/skills/
│   └── postgres-learning/
│       ├── SKILL.md
│       └── references/                 roadmap.md, quiz.md
└── templates/                       (not synced) — GitHub-side files
    └── pull-request.md                 copy into a repo's .github/
```

- **Agents** = interactive personas (tutor, coding partner, reviewer).
- **Skills** = on-demand domain content (roadmaps, quizzes, procedures) that agents load.
- The folder name of a skill must match the `name` in its `SKILL.md` (lowercase + hyphens).
- **Templates** = neither. GitHub-side files (a PR template is read by GitHub from a repo's
  `.github/`), kept here only so there is one canonical copy. Unlike `agents/` and `skills/`,
  `templates/` is **not** synced to `~/.copilot/` — `copilot_restore` copies only those two
  folders. To apply a template, copy it into the target repo as `.github/pull_request_template.md` —
  the source filename is deliberately not the GitHub one, since it is not a drop-in file here.

## Using the agents

`tutor` is a subject-agnostic teaching persona. The domain is loaded into it by a matching `*-learning` skill (e.g. `postgres-learning`), so adding Redis or auth means adding a skill, never editing the agent. Name the topic (e.g. *"teach me Postgres from zero"*) and the skill loads automatically; steer the lesson with **fast/speedrun**, **slow/thorough**, **review/quiz me**, or **just tell me**.

`meta-agent-reviewer` audits an `.agent.md` or `SKILL.md` and returns a scorecard on scope, tool scoping, and structure.

`merge-reconciler` is invoked on a feature branch whose base has moved ahead — say `main` after a different feature merged. It reports what landed on the base, surfaces textual and semantic conflicts, proposes resolutions, applies only what you approve, then runs the repo's checks to prove both the merged-in feature and this branch still work.

