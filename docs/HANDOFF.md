# Handoff

The first thing a new session reads.

## Where things stand

Phase: **design**. Research was closed by the developer on 2026-11-14. [02-design.md](02-design.md) is a draft proposal by Claude; the developer has not confirmed it. D1–D4 are decided (capture on a landing screen with no always-on notification, which withdraws research Q7; one item or three by setting; German and English; birthdays first after the core). D5–D8 are open in its §6. A first concept canvas with nine screens exists (02-design.md §6.1, sources in `docs/concepts/`). The developer reviewed it on 2026-11-15: too boring, clinical and business-like. A more playful V2 with six screens and a new upcoming timeline (D9) is on the same canvas (02-design.md §6.2); the developer found V2 slightly overshot and asked for a V3 tryout in Material 3 Expressive with dark mode and no emoji (§6.3), which the developer found more mature but lacking character and with boring icons. The V4 tryout (V3 plus shadows, tilted notes, confetti, colourful icons; §6.4) was liked. V5 (§6.5) was accepted as the direction, except its off-centre stamps. V6 (§6.6) is the full set of twelve screens in that look, with stamps only tilted and a new compact per-friend timeline (D10); the developer likes it (review in §6.7). Four screens also exist in light mode. No code, no git repository yet.

Note: the "Open points" lists below are per-session history. Q7 (capture notification) is withdrawn and research is closed; the current open points are D5–D9 in 02-design.md §6 and the M0 checks.

The idea: an app for a person with ADHD who loses touch with friends and wants to reconnect with childhood friends. The developer has ADHD and is the first user. The developer has built one Flutter app with Claude before (akai-timetrack).

## Done in the 1st session (2026-11-13): setup and market scan

- Copied the working mode from akai-timetrack into [CLAUDE.md](../CLAUDE.md).
- Market scan written to [01-research.md](01-research.md) §2. Result: the space is crowded (Kinu is closest), but no app closes the step from reminder to sent message, and reconnecting after years is barely covered. The scan rests on blogs, not on store reviews.

## Open points (in rough priority)

Decided: build it (Q1), Android first (Q3). Key finding from the developer's answers (01-research.md §5): the core problem is that the intention to contact someone gets lost between the moment of the thought and a moment with time. The app centres on fast capture and good resurfacing, not on contact cadence.

Also decided: people only for now (Q4), doctor appointments in the backlog (B1). Feature candidates F1–F8 and the backlog are in 01-research.md §6. Birthdays with an evening "Congratulated yet?" notification are wanted (F5).

Also decided: start with the evening question, no home-screen widget (Q5). Friend classes (F9) and switchable gamification (F10) are feature candidates. Technical findings are in 01-research.md §8; the points marked (U) are unconfirmed.

Also decided: personal tool for now with Play compatibility kept in mind (Q2), several forgiving forms of gamification (Q6), capture through a notification that stays at the top (Q7), no pre-filled texts (Q8). Q1–Q8 are all decided.

## Done in the 2nd session (2026-11-14): evidence check

- The developer chose more research before design. Evidence on ADHD and friendship rhythms is in 01-research.md §9. It is thin: one solid finding (time-based remembering is the weak spot, outside cues work better), the rest is inference.

- The developer supplied six papers (`docs/papers/`, keep out of git). Read in full by subagents; findings in 01-research.md §9.5, consequences in §9.6. Main result: in adult ADHD the bigger gap is between remembering an intention and acting on it ("did not feel like it"), so the step after the nudge matters as much as the nudge. The earlier "time-based remembering" claim was corrected.
- Reading PDFs needs `poppler-utils` (installed 2026-11-14).

## Open points (in rough priority)

1. The developer answered on acting, reconnecting and meeting up (01-research.md §9.7, §9.8). The ideas drawn from the answers are not yet confirmed. Decided (Q9): try auto-detect of owed replies through the notification listener, as an optional part with "the app asks" as fallback.
2. Research stays open until the developer closes it. Then start 02-design.md.
3. Confirm the (U) points in 01-research.md §8 and the Discord link (§9.4) in a prototype during M0, first of all the capture notification.

## Done in the 3rd session (2026-11-15): concept V2

- Developer feedback on the first concept: boring, clinical colours, business-like; wants more playfulness and a timeline of upcoming events.
- V2 row added to the canvas (six screens, sticker look, emoji avatars, stamp card for treats, Upcoming tab). Proposals only. Not rendered by Claude.
- Developer feedback on V2: good idea, slightly overshot; likes the stamp card and the timeline; no emoji as icons; wants dark mode; asked for a tryout mixing V2 with Material 3 Expressive. V2 stays on the canvas.
- V3 tryout row added (Home, Upcoming, Progress in dark and light; Material Symbols, initials in shapes). See 02-design.md §6.3. Waiting for the developer's yes or no. The ENIX icon pack style could not be looked up.

- Developer feedback on V3: step forward and more mature; misses the tilted notes, the shadows and the confetti of V2; icons too boring, wants colourful ones tried (ENIX screenshots supplied), is split on plain icons on coloured areas.
- V4 tryout row added (dark; Home in two icon variants, Upcoming, After "Yes, I wrote", One person, Progress). See 02-design.md §6.4. Waiting for the developer's verdict and the choice between icon path A and B.
- The developer moved a board on the canvas. Before publishing, read the canvas's `project/canvas.json` and build on it.
- Material 3 Expressive in Flutter: use `material_3_expressive`, as in akai-timetrack (02-design.md §4).

- Developer feedback on V4: loves icons, shadows, tilted date badges, stamps. Colourful icons everywhere for now. Large cards straight, small things tilted. Wants the messenger's app icon on "Open chat" and slightly misaligned stamps. Asked for a V5 that leaves V4 in place.
- V5 row added (Home, Upcoming, After "Yes, I wrote", One person, Progress). See 02-design.md §6.5. Next: the developer's verdict, then the remaining screens (People, notifications, first start, settings) in the V5 look, and a search for a colourful icon pack.
- Rule from the developer: new concept versions get a new row. Do not overwrite a row the developer has seen unless asked.

- Developer feedback on V5: draw the remaining screens; off-centre stamps rejected; wants a compact history-and-upcoming timeline per friend.
- V6 rows added (twelve screens, see 02-design.md §6.6). Next: the developer's review of V6, then D5, D6, D8, D9, D10, the icon pack question and the OK on technology and milestones.

- Developer review of V6: great; settings behind the gear and messenger icons decided; coral buttons and the naming notification kept for now; "Friends" stays as working name. New wishes: record who reached out and birthday wishes in both directions (D11); later, shared events show all friends' bubbles. See 02-design.md §6.7.
- Light-mode row added to the canvas (four screens).
- Decided after the V6 review (02-design.md §6.8): how birthdays show in the friend timeline, the compact friend timeline (D10), tilted stamps.
- Settled with the developer (02-design.md §6.9): classes, stamps per treat with a default list, incoming contact, no call log, Upcoming content, undated plans with a horizon. The stamp rule, default treats, rhythm numbers and the resurfacing of undated plans are confirmed (§6.10). Open: app name, icon sources, milestones (need updating for the new features), data sketch §3. Technology is approved (02-design.md §4); the chat-opening package is chosen in M0.
- Older next-step line, partly done: settle D5, D6, D8, D9, the rest of D11, update the data sketch (§3) for dates and direction, look for a colourful icon pack, get the OK on technology and milestones.

- Data sketch (02-design.md §3) and milestones (§5, now M0 to M10) updated for today's decisions. The milestones are not yet confirmed by the developer.
- V6b tweak row on the canvas (shadows on grey buttons and people blobs, a "More" blob instead of the magnifier), not yet reviewed (§6.11).
- Future idea recorded: quick do-soon items such as listening to a long voice message, kept out of the timelines (02-design.md §6.12).
- Milestones M0 to M10 approved by the developer (2026-11-15).
- Still open after that approval: app name (D8), icon sources (§6.5), review of V6b; then the developer can close the design phase. Older line: app name (D8), icon sources (§6.5), OK on milestones, review of V6b. After that the design phase can be closed by the developer.

- Icon sets searched and compared on a canvas board (02-design.md §6.13). Only Fluent Emoji Flat (MIT) is a real alternative to our own drawn icons. Waiting for the developer's choice.

- Own icons decided; style guides written: `docs/style/ui-style.md`, `docs/style/icon-style.md` (02-design.md §6.14).

## Checking concept screens

`gen_v6.py` takes a third argument, a folder for plain HTML previews. Headless Edge on the Windows side can screenshot them from WSL:
`"/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless=new --window-size=1230,850 --virtual-time-budget=8000 --screenshot="$(wslpath -w out.png)" "$(wslpath -w preview1.html)"`

## Working in this repo

- Git repository since 2026-11-15, branch `main`, remote `origin` = https://github.com/Kraechtshammer/friendsapp.git. First commits are local; push only when the developer asks. `docs/papers/` and the icon comparison board (third-party icons) are git-ignored and stay local.
- Before the first push, the developer should know: 01-research.md describes the developer's own situation (§5, §9.7, §9.8). Fine for a private repository; a point to decide for a public one.
- Next: set up VS Code so that cloning and opening the folder is enough (extensions installed automatically), and commit that separately. akai-timetrack uses a dev container with a solved adb setup (`.devcontainer/`, `docs/03-dev-setup.md` there); **Decided (the developer, 2026-11-15): dev container**, with the emulator included (needed for README screenshots). Wishes: demo contacts for screenshots, and one emulator shared by all the developer's app projects. Claude's plan, not yet confirmed: mount the same emulator volume that akai-timetrack uses (`timetrack-emulator`) so image and device are shared, and give the app a debug-only "demo data" switch that fills it with invented people instead of relying on emulator contacts.
- Commit in small increments with short messages (CLAUDE.md).
