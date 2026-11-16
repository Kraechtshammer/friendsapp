# Handoff

The first thing a new session reads. Last rewritten on 2026-11-16, at the end of the session that built M0, M1 and most of M2. The log of the research and design sessions is in [history-research-and-design.md](history-research-and-design.md).

## 1. Where things stand

- Phase: **implement**. The app is called **Kept.** with the full stop (app label and titles; running text may write Kept). App ID `de.gartenpa.kept` (final). Repository and folder are `friendsapp`.
- **M0 and M1 are done. M2 (Capture) is built but not yet tried by the developer.** See section 4.
- **Released: 0.1.0** (tag `v0.1.0`, the state at the end of M1). The release workflow ran for the first time and passed: signed APK `kept-0.1.0.apk` on the public GitHub release.
- Pushed up to the M2 data layer. The capture UI and this handoff are committed locally and not pushed.
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

**M2, Capture: built, to be tried** (2026-11-16).

- Done: `intentions` table with the migration from schema 1 to 2; capture card on Home (text, person from the recent four or through "More", kind, Save); open thoughts listed on Home and on the person page with Done and Drop; greeting by time of day; long-press shortcut "Capture a thought" (`quick_actions`); the class badge on avatars on Home. Checked: analyze, 73 tests, debug build installed on the phone. **Not checked: Claude has not looked at the capture screens, in a picture or on the phone; the developer has not tried them; the long-press shortcut and the database upgrade on the phone are untested.**
- Next: the developer tries capture on the phone. Fix what they find. Then raise the version to 0.2.0+2 in pubspec.yaml, commit ("Release: 0.2.0"), tag `v0.2.0` and push, if the developer agrees.
- Known gaps: recent people are ordered by open intentions only; German texts in M1 and M2 were written by subagents and not all reviewed by the developer.

**Next milestone: M3, evening question and open items** (02-design.md §5): the daily notification, Yes leads to the open items, "Did you write?" and the "Nice one" screen, contact events stored. Needs a contact events table (migration to schema 3) and the notification code. Ask the developer before fixing the data model. M3 is the first version for daily use and becomes 0.3.0.

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
- **Tags are releases.** Every tag is `v<version>` matching pubspec.yaml; pushing it runs the release workflow (signed APK, public GitHub release). No other tags. The minor number follows the milestones (M3 is 0.3.0); 1.0.0 is the first real release. The build number after the `+` goes up with every release.
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
