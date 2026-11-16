# Handoff

The first thing a new session reads. Last rewritten on 2026-11-16, at the end of the session that built M0, M1 and most of M2. The log of the research and design sessions is in [history-research-and-design.md](history-research-and-design.md).

## 1. Where things stand

- Phase: **implement**. The app is called **Kept.** with the full stop (app label and titles; running text may write Kept). App ID `de.gartenpa.kept` (final). Repository and folder are `friendsapp`.
- **M0 to M6 are built.** The developer has tried up to M4; notifications (M3, M4) are being tried in daily use. M5 and M6 are untried on a phone. See section 4.
- **Released: 0.4.0** (tag `v0.4.0`, 2026-11-16, M5 and M6). Before it: 0.3.0 (M4), 0.2.0 (M2 and M3), 0.1.0 (M1). The developer's phone has the M4 debug build; nothing later was installed there.
- Everything up to the 0.4.0 release commit is pushed (2026-11-16).
- The developer uses the app with real people on their Pixel 7 Pro since 2026-11-16. **Every database change needs a tested migration.**

## 2. What to read, and how much

1. [CLAUDE.md](../CLAUDE.md): the working rules. Short.
2. This file.
3. [02-design.md](02-design.md): §3 data, §4 technology, §5 milestones, §8 everything decided or tested during implementation. Section 6 is the long history of how each point was settled; section 3 of this handoff sums up its results, so read §6 only when a detail is needed.
4. [style/ui-style.md](style/ui-style.md) and [style/icon-style.md](style/icon-style.md) before building any screen.
5. [03-dev-setup.md](03-dev-setup.md) for the container, phone, emulator, CI and releases.
6. [04-architecture.md](04-architecture.md) for how the code is laid out. It follows `/home/paga/Projects/akai-timetrack/docs/04-architecture.md`; look there for the layers that are not built yet.

The reference for the look is concept V6 with the V6b tweaks: pictures in `docs/concepts/previews/v6-*.png` and `v6b-*.png`, every value in `docs/concepts/gen_v6.py`.

## 3. The design in short

02-design.md §2 was written early. Where it differs from this list, this list (taken from §6.5 to §6.14) is right.

**Core**

- The user opens the app to capture a thought: text, person, kind (write, call, meet). No always-on notification.
- Once a day, at a set time and not on excluded days: "Got ten minutes for someone today?" with Yes and Not today. Not today costs nothing. Nothing is ever shown as overdue.
- Home shows the capture card, the open item ("Tonight's pick") or a list of three (a setting), and the next two dates.
- "Open chat" opens the person's main messenger and carries that messenger's icon. On return: "Did you write to Tom?", then the "Nice one" screen with confetti, a line for next time, and "Planning to meet up?".
- Pick order: birthday today, longest owed reply, reconnect person of the week, own intentions and undated plans, class rhythm hint.

**People**

- Classes: Close friends, Now and then, A few times a year; Family is a separate group. "Getting back in touch" is a state on top. Default rhythms 2 weeks, 6 weeks, 3 months, editable in settings. A rhythm only drives a gentle hint.
- A person is shown by their initial in a coloured shape. No photos, no emoji.

**Time**

- Upcoming tab: birthdays for the next 12 months and anything with a date. After a date has passed the app asks once "Did it happen?".
- Plans without a date have a horizon: soon, later, or when… with a condition. "Soon" comes back as an evening pick after about two weeks, "later" after about two months, "when…" never by itself.
- Each person has a compact timeline on their page: upcoming on top, history below.
- Contact is recorded in both directions. Incoming: automatically where the notification listener is on, plus "They wrote" and "They called" buttons.
- Birthdays: their birthday always shows in their timeline, with "You congratulated" when the user did. The user's own birthday shows only for people who congratulated.

**Stamps and treats**

- At most one stamp-earning contact per person per week. Value: 1 (close), 2 (now and then), 3 (a few times a year), +1 if getting back in touch, +1 if the last contact was longer ago than the rhythm, doubled for a meet-up. Weights and card sizes are editable in settings.
- Each treat has its own number of stamps (default 10). A default list of treats ships with the app (02-design.md §6.9, §6.10).
- Progress shows a count that only grows, the stamp card, the week, weeks in a row that pause instead of resetting.

**Permissions and Play**

- Contacts (read). Notifications. Notification access is optional, switched on by hand, own Kotlin code.
- No call-log permission. Messenger calls may be recognised through notification access (to test).
- Anything that adds a permission or could risk Play compatibility is discussed first.

**Look**

- Dark first, light as well, plus a theme setting. Settings open from a gear on Home; the tabs are Home, Upcoming, People, Progress.
- Own colourful icons, drawn to the icon style guide. Sixteen exist as SVG in `gen_v6.py` (`ICONS`).

**Later, not in the milestones:** groups and shared events, quick "do soon" items such as a voice message to listen to (§6.12), doctor appointments, iOS.

## 4. Milestones: state and next steps

Details of what was built are in [04-architecture.md](04-architecture.md); decisions and phone test results are in 02-design.md §8.

**M0, setup and risk checks: done** (2026-11-15). All five phone checks passed: no exact-alarm permission needed, notification buttons work with the app closed, chats open through `android_intent_plus`, the own listener sees WhatsApp messages and calls, own drawn messenger icons. The throwaway check code is in git history (commit "Dev: Add throwaway phone checks for M0"), a starting point for M3 and M7.

**M1, People: done** (2026-11-16). Database with settings and people, demo database behind a debug switch, People tab, person page top, add and edit, import from contacts, "Open chat", class shown as a growing plant. The developer tried it on the phone: "all worked well". Not confirmed by the developer: that "Open <messenger>" lands in the right chat from the final code.

**M2, Capture: done, not released** (2026-11-16).

- Done: `intentions` table with the migration from schema 1 to 2; capture card on Home (text, person from the recent four or through "More", kind, Save); open thoughts listed on Home and on the person page with Done and Drop; greeting by time of day; long-press shortcut "Capture a thought" (`quick_actions`); the class badge on avatars on Home. Checked: analyze, 73 tests, debug build installed on the phone. **Not checked: Claude has not looked at the capture screens, in a picture or on the phone; the developer has not tried them; the long-press shortcut and the database upgrade on the phone are untested.**
- M2 was not released by itself; it went out together with M3 in 0.2.0.
- Known gaps: recent people are ordered by open intentions only; German texts in M1 and M2 were written by subagents and not all reviewed by the developer.

- Tried by the developer on 2026-11-16: "all worked". The developer chose not to release 0.2.0 yet.

**M3, evening question and open items: done, released as 0.2.0** (2026-11-16). 02-design.md §5; decisions of the day in §8 (kind "game", activity text, line for next time with a "Remind me" switch, Done records a contact).

- Done: schema 3 with `contact_events` and `day_answers`, their repositories, the kind `game` (label Game / Zocken, shown with the meet icon for now). Checked: analyze, 92 tests, among them the upgrade from 2 to 3 with people, intentions and settings compared row by row. **Not checked: the upgrade on the phone; no screen uses the new tables yet.**
- Done: Done on an open thought (Home and person page) stores a contact with source "by hand" and opens the "Nice one" screen: activity for meet and game (prefilled from the thought's text), line for next time, "Remind me" switch; "Last time: ..." under open thoughts. The controller is the Game icon (`assets/icons/controller.svg`). Checked: analyze, 100 tests, Claude looked at a rendered picture of the screen (`build/screens/`). **Not checked: on the phone; the developer has not seen the screen.** Left out against the concept: the "High five!" tag, "Planning to meet up?" (M5), stamps (M9), motion. The button reads "Close" (Claude's choice). German texts by a subagent, not reviewed.
- Icons: Meet shows the two people icon for now (the People tab uses the same one). The developer wants simple icons of few plain shapes; a cheap model or Claude's own small SVG edits are enough. In the set since 2026-11-16: `controller` (Game), `cups`, `wasd`, `bench` (the last three not used yet) and the new `phone` (half-rounded-rectangle ends, from the developer's sketch). Open: the bench with tree, the bench with tree is in the set as `bench` (the developer may still edit it by hand). Do not delete drafts the developer has seen: the bench had to be redrawn from a screenshot.
- On the phone: the M3 debug build was installed on 2026-11-16 (`adb install -r`, Success), so the real database is at schema 3 once the app was opened. The developer tried it the same day: "everything else looks good"; the evening notification was not tried ("let's assume it works"), so every notification point above stays unchecked.
- Done: the evening question. Daily notification "Got ten minutes for someone today?" with Yes and Not today, settings section with on/off, time (start 19:00) and excluded weekdays (start none, Claude's start values), permission asked on first start and when switched on. Checked: analyze, 119 tests, debug APK builds. **Not checked, all on the phone:** the permission dialog on first start; arrival on allowed days only and after a restart (weekly repeating notifications are new, M0 tested single ones); Not today with the app closed stores the answer and leaves the app closed; Yes from cold and from running opens Home at the open thoughts; the line and button after refusing the permission; the sprout status icon; a release build (the icon is kept through `res/raw/keep.xml`).
- Done: "Tonight's pick" on Home (one item with Open chat, Another one, Done; or three, by setting) from the open thoughts, oldest first, one per person (Claude's order until other sources exist); "Did you write to Tom?" after any Open chat (pick or person page), worded by kind, Yes leads to "Nice one". Checked: analyze, 133 tests, Claude looked at rendered pictures (`build/screens/home-one.png`, `chat-question.png`). **Not checked: on the phone, above all that the question appears when coming back from the messenger.** Against the concept: Another one and Done are text buttons under a full-width Open button; Yes says "Yes"; no "High five!" tag.
- Still open in M3: the evening notification is untried on the phone, in debug and in the release build (points above). German texts of M3 are by subagents and not reviewed.

**M4, birthdays: done, released as 0.3.0** (2026-11-16). The developer on the debug build: "so far it looks good"; the notifications are being tried in daily use over the next days. Decisions in 02-design.md §8 (last rows).

- Done: on the day, the person is the first pick on Home ("Turns 32 today", Open chat, Congratulated); "Did you congratulate ...?" after Open chat; two notifications per birthday (evening time, and 23:00 if not congratulated) with Yes and Open chat, in addition to the evening question and also on excluded days; "Your birthday" in Settings; "Who congratulated you?" card on the user's own birthday with a screen of toggles. No schema change. Checked: analyze, 167 tests, debug APK builds, Claude looked at a rendered Home picture (`build/screens/m4-home-birthday.png`). The M4 debug build was installed on the developer's phone on 2026-11-16. **Not checked: anything on the phone; the developer has not reported yet.** Phone list: both notifications arrive; Yes with the app closed stores the wish and removes the 23:00 one (cancelling from the background isolate is unverified); Open chat from a cold start, then the return question; the Birthdays channel in Android settings.
- Known gaps: if the background handler dies between storing and cancelling, the 23:00 ping still fires; congratulating in demo mode does not cancel real notifications; Home does not notice midnight while it stays open; a person with a birthday pick shows no thought pick until congratulated; a Yes tapped after midnight is stored at 23:59 of the birthday. German texts by a subagent, not reviewed.
- **Working mode since 2026-11-16 (the developer):** Claude keeps building the remaining milestones up to 1.0.0 without waiting for a test of each one, keeps [05-test-list.md](05-test-list.md) up to date with what the developer should check, and makes reasonable releases now and then (next number each time, no skips). Choices Claude makes alone on the way are marked as Claude's in 02-design.md §8, for the developer to overrule. Still to ask first: new permissions, anything that risks Play, new dependencies.
**M5, Upcoming and plans: built, not tried** (2026-11-16). No schema change.

- Done: "when" on a thought (date with optional time, Soon, Later, When... with a condition) on the capture card and in a new edit sheet (tap a thought); the Upcoming tab (birthdays and dated thoughts for 12 months, "No date yet" in three groups); "Coming up" cards on Home; "Did it happen?" once after a date (Yes records the contact, No moves it back to Soon); due plans as picks ("Want to set a date with ...?"). Checked: analyze, 224 tests, Claude looked at rendered pictures (`build/screens/m5-*.png`). **Not checked: on the phone.**
- Claude's choices, not confirmed: see 02-design.md §8. Notable: tapping a thought on Home now opens the edit sheet, not the person page.
**M6, friend timeline: built, not tried** (2026-11-16). No schema change.

- Done: the compact timeline on the person page (upcoming, a Today mark, history with who did what, activity and note, birthdays in both directions, "Added to your people"); "They wrote" and "They called" buttons (once per day, with Undo); a sheet to edit or delete a history entry. Checked: analyze, 248 tests, Claude looked at the dark render (`build/screens/m6-timeline-dark.png`). **Not checked: on the phone. The small direction arrows show as empty boxes in the test render (the test font lacks them); whether they show on the phone is open.**
- M5 and M6 are released together as 0.4.0.
- Next: one migration to schema 4 for everything M7 to M10 need, then M7.

## 5. Open questions for the developer

- A first-start welcome screen: there is none; the empty People tab offers "Add from contacts" and "Add by hand" (Claude's choice). Wanted?
- The person page covers the tab bar; the concept shows the bar. Keep?
- Row classes of the database are used as models, as in akai (Claude's choice).
- Other companies' logos (messenger icons) in a published app touch their brand rules. Look at this before a Play release.
- The repository is public and 01-research.md describes the developer's own situation (§5, §9.7, §9.8). Mention it once more if the repository gets promoted.

## 6. Not tested yet

- The light theme on a phone.
- The shared emulator from this container.
- Long delays of the evening notification in deep sleep (the M0 test ran on charge).
- Signal with a user-name link, Discord with a user ID.

## 7. How to work here

- **Flutter runs in the dev container, not in WSL.** From a Claude session in WSL: find the container with `docker ps` (its image name starts with `vsc-friendsapp`), then `docker exec -u vscode <name> bash -lc 'cd /workspaces/friendsapp && flutter analyze'`. The container only runs while the developer has the folder open in VS Code.
- **Installing on the phone:** the container does not see the phone unless the developer runs `scripts\windows\start-adb-server.cmd`. What works from WSL: build in the container (`flutter build apk --debug --target-platform android-arm64`, smaller), copy `build/app/outputs/flutter-apk/app-debug.apk` to `/mnt/c/Windows/Temp/`, then from that folder `cmd.exe /c "adb install -r <file>"`. The phone is often nearly full; an install then fails with "not enough space" and the developer has to free about 1 GB.
- **Looking at a screen without the phone:** see 04-architecture.md §2.4 (throwaway widget test that writes pictures).
- **Git runs in WSL** in `/home/paga/Projects/friendsapp`. Push works through the Windows Git Credential Manager (set per repository). Push only when the developer asks.
- **Commits:** small, one finished step each, subject with prefix (the hook checks it), short messages. End each message with the attribution line the session gives.
- **Token use:** keep it low, and keep messages to the developer short. The main session plans, writes the briefs, reviews and decides. Building goes to subagents, the smallest model that keeps the quality: Sonnet for screens and edits with a precise brief, Opus only for work where a mistake is costly (database and migrations, native code), Haiku for mechanical doc edits with the exact text given. One agent per set of files; each brief names what must not be touched and asks for a short report. Check every result yourself: rerun analyze and tests, read the risky parts.
- **Tags are releases.** Every tag is `v<version>` matching pubspec.yaml; pushing it runs the release workflow (signed APK, public GitHub release). No other tags. **No version is ever skipped** (the developer, 2026-11-16): each release is the next number after the last one, whatever milestones it holds; the minor number does not follow the milestone numbers. 1.0.0 is the first real release. The build number after the `+` goes up with every release.
- **Ask first** before design trade-offs, new dependencies, names, and anything touching permissions or Play.
- **Secrets:** never read `android/key.properties` beyond single non-secret lines, never print the keystore, never put secrets into git, chat or docs.
- **Papers** in `docs/papers/` are local only.
- A leftover Docker image `friendsapp-devcontainer-check` (about 16 GB) from a test build can be removed with `docker rmi friendsapp-devcontainer-check`.

## 8. Concept canvas

Only needed if a screen has to be redrawn or a new one sketched.

- The canvas is a private Claude artifact: https://claude.ai/artifact/WW7Y4AiXwbDkKEJYGePfhR. Its sources are in `docs/concepts/` (`canvas.json` plus one `.dc.html` per board).
- `python3 docs/concepts/gen_v6.py <project folder> docs/concepts <preview folder>` regenerates the V6 boards and writes plain HTML previews.
- Previews can be turned into pictures from WSL with headless Edge:
  `"/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless=new --window-size=1230,850 --virtual-time-budget=8000 --screenshot="$(wslpath -w out.png)" "$(wslpath -w preview.html)"`
- Before publishing to the canvas, read its current `project/canvas.json` and build on it: the developer moves boards. New versions get a new row; do not overwrite a row the developer has seen.
- The icon comparison board and its picture embed third-party icons and are git-ignored.
