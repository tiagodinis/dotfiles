# Copilot Custom Agents & Skills

Source of truth for personal GitHub Copilot agents and skills, synced to the user profile (`~/.copilot/`) by the dotfiles save/restore scripts.

## Layout

```
copilot/
├── agents/                          → ~/.copilot/agents/         (user-level custom agents)
│   ├── meta-agent-reviewer.agent.md    audits agent/skill quality
│   └── tutor.agent.md                  Socratic tutor (behavior only; loads skills)
└── skills/                          → ~/.copilot/skills/
    └── postgres-learning/
        ├── SKILL.md
        └── references/                 roadmap.md, quiz.md
```

- **Agents** = interactive personas (tutor, coding partner, reviewer).
- **Skills** = on-demand domain content (roadmaps, quizzes, procedures) that agents load.
- The folder name of a skill must match the `name` in its `SKILL.md` (lowercase + hyphens).

## Using the agents

`tutor` is a subject-agnostic teaching persona. The domain is loaded into it by a matching `*-learning` skill (e.g. `postgres-learning`), so adding Redis or auth means adding a skill, never editing the agent. Name the topic (e.g. *"teach me Postgres from zero"*) and the skill loads automatically; steer the lesson with **fast/speedrun**, **slow/thorough**, **review/quiz me**, or **just tell me**.

`meta-agent-reviewer` audits an `.agent.md` or `SKILL.md` and returns a scorecard on scope, tool scoping, and structure.

