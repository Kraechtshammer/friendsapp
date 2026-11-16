# Kept. (repository: friendsapp)

An app that helps a person with ADHD stay in touch with friends and reconnect with old ones.
The app is called **Kept.** with the full stop (decided 2026-11-15; running text may write Kept without it); the repository and folder keep the name friendsapp. Current phase: **implement** (research closed 2026-11-14, design closed 2026-11-15). Milestones M0 to M10 are in docs/02-design.md §5.

**Read [docs/HANDOFF.md](docs/HANDOFF.md) first.** It says where things stand and what is open.

## Where things are

| Path | Purpose |
|---|---|
| [docs/HANDOFF.md](docs/HANDOFF.md) | State, per-session log, open points. Updated every session. |
| [docs/history-research-and-design.md](docs/history-research-and-design.md) | Log of the research and design sessions. History only. |
| [docs/01-research.md](docs/01-research.md) | Problem, market, features (F#), decisions (Q#). The record of why. |
| [docs/02-design.md](docs/02-design.md) | Behaviour, data model, screens, milestones (M#). Closed; later changes go into its §8. |
| docs/papers/ | PDFs the developer supplied. Copyrighted: local only, git-ignored, never commit. Reading PDFs needs `poppler-utils`. |
| [docs/style/ui-style.md](docs/style/ui-style.md) | The look: colours, type, shadows, components. Written to be reusable for other apps. |
| [docs/style/icon-style.md](docs/style/icon-style.md) | How the app's own colourful icons are drawn. Follow it for every new icon. |
| docs/concepts/ | Concept screens (canvas sources, generators, rendered pictures). New concept versions get a new row; do not overwrite one the developer has seen. |
| [docs/03-dev-setup.md](docs/03-dev-setup.md) | Dev container, phone, emulator, git. Builds and releases follow with the app. |
| [docs/04-architecture.md](docs/04-architecture.md) | Layers, code style, known weaknesses. Updated with every structural change. |
| [docs/05-test-list.md](docs/05-test-list.md) | What only the developer can check on the phone. Claude adds points with every milestone; the developer ticks them. |

The working mode is taken from `/home/paga/Projects/akai-timetrack` (same developer, Flutter). Look there for examples of finished docs.

## Phases

Research, then design, then implement. Do not start a phase until the developer has closed the previous one. Decisions get an ID, a date and the author, and are not rewritten later: deviations are listed separately.

## Working agreements

- The developer writes in German or English; answer in English unless they switch. Docs, code comments and commit text are English.
- Ask before design trade-offs, adding dependencies or naming things. Offer the options with a recommendation.
- Personal tool for now, possibly published later. Before anything that could risk Google Play compatibility or adds a permission, discuss it with the developer. Experiments on the developer's own phone are fine once agreed.
- Keep token use low. Fable does the reasoning and the synthesis. Hand simple or bulky work (web research, file sweeps, mechanical edits) to Haiku, Sonnet or Opus subagents with a narrow written brief, then check their results yourself. Use the smallest model that keeps the quality, and keep messages to the developer short. Never let two agents edit the same files.
- Docs are the project's memory. Update HANDOFF.md and the phase doc in the same step as the work they describe.
- Commits: small increments, one finished step each, never half the project in one commit. Subject prefixed with Feature / Bugfix / Improvement / Docs / Dev / Release. Keep messages short: if a message needs a long body to list what was done, the commit is too big. Push only when the developer asks.
- Tags are releases: every tag is `v<version>` matching pubspec.yaml and publishes a GitHub release. No other tags.
- Report honestly what was checked and what was not.
- Secrets never go into git, chat or docs.

## Writing style for docs

Plain English, short sentences, no marketing words. "The user" is the person using the app; "the developer" is the person building it. Mark unverified claims as unverified.
