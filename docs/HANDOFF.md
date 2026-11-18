# Handoff

The first thing a new session reads. Last rewritten on 2026-11-16, after the review of Claude's choices, the first-start flow and the in-app update. The log of the research and design sessions is in [history-research-and-design.md](history-research-and-design.md).

## 1. Where things stand

- Phase: **implement**. The app is called **Kept.** with the full stop (running text may write Kept). App ID `de.gartenpa.kept`; debug builds use `de.gartenpa.kept.debug`. Repository and folder are `friendsapp`.
- **M0 to M10 are all built.** Everything is released; the newest release is 0.9.1.
- **Released** (tags `v0.1.0` to `v0.9.1`, all 2026-11-16, no version skipped):
  - 0.1.0: M1, people, contacts import, "Open chat".
  - 0.2.0: M2 and M3, capture, the evening question, Tonight's pick, "Nice one".
  - 0.3.0: M4, birthdays.
  - 0.4.0: M5 and M6, Upcoming and plans, the friend timeline.
  - 0.5.0: schema 4, M7 to M9, owed replies, rhythm and reconnect, stamps and treats.
  - 0.6.0: M10, ideas and sharing into the app.
  - 0.7.0: the review changes, the first-start flow, the permissions page, refresh from contacts, the licences row, the K. launcher icon, the in-app update, the evening ping naming its reason, a clean-up of unused code.
  - 0.8.0: incoming messages as a build flag; two APKs per release (plain, and `-listener`), the updater keeps each build on its kind.
  - 0.9.0: schema 5; settings as categories with icons; language setting; predictive back; short display names, nicknames, pictures (contacts, gallery, shared in with a crop screen).
  - 0.9.1 (2026-11-17): couples screens (Partner row, couple page, couple thoughts, shared meetings). Wanted later: a name for a couple.
- **1.0.0 is not soon (the developer, 2026-11-16):** the developer tests for days or weeks first. Until then releases keep taking the next number (0.9.2 next).
- **The developer's phone** (2026-11-16): `de.gartenpa.kept.debug` ("Kept. debug", 0.7.0, test data). The old 0.6.0 debug build under `de.gartenpa.kept` is left only in the Private space (user 11), never opened there; it blocks the release install (signature) and the developer removes it by hand (Claude's uninstall was refused). Then the listener build of the release goes on over adb.
- **The developer's phone since 0.8.0:** the release listener build `kept-0.8.0-listener.apk` is installed over adb as the real app; 0.9.0 is its first real in-app update test. The developer said on 2026-11-16 that commits may be pushed right away.
- **Play Protect blocks sideloaded APKs with a notification listener** (found 2026-11-16 on the Pixel 7 Pro: "The app can request access to sensitive data..."). Since then the listener is the build flag `KEPT_INCOMING` (03-dev-setup.md). Each release publishes `kept-<v>.apk` (no listener, installs from the browser) and `kept-<v>-listener.apk` (for the developer, installed over adb); the updater keeps each build on its own kind. Whether Play Protect lets the app's own updater install the listener APK is unverified. A Play internal testing track would be the legal way to ship the listener to others.
- Pushed: everything up to the 0.7.0 release commit. Later docs commits are local until the developer asks for a push or the next release.
- **Tried by the developer:** M1 to M4 on the phone (M2 "all worked", M3 "everything else looks good", M4 "so far it looks good"); the evening and birthday notifications are being tried in daily use and have no report yet. The 0.6.0 debug build was installed on 2026-11-16; there is no report on the migration to schema 4 or on M5 onward. **Every database change needs a tested migration.**

## 2. What to read, and how much

1. [CLAUDE.md](../CLAUDE.md): the working rules. Short.
2. This file.
3. [02-design.md](02-design.md): §3 data, §4 technology, §5 milestones, §8 everything decided or tested during implementation. Section 6 is the long history of how each point was settled; section 3 of this handoff sums up its results, so read §6 only when a detail is needed.
4. [style/ui-style.md](style/ui-style.md) and [style/icon-style.md](style/icon-style.md) before building any screen.
5. [03-dev-setup.md](03-dev-setup.md) for the container, phone, emulator, CI and releases.
6. [04-architecture.md](04-architecture.md) for how the code is laid out. It follows `/home/paga/Projects/akai-timetrack/docs/04-architecture.md`; look there for the layers that are not built yet.

The reference for the look is concept V6 with the V6b tweaks: pictures in `docs/concepts/previews/v6-*.png` and `v6b-*.png`, every value in `docs/concepts/gen_v6.py`.

## 3. The design in short

02-design.md §2 was written early. Where it differs from this list, this list (from §6 and §8) is right.

**Core**

- The user opens the app to capture a thought: text, person, kind (write, call, meet, game), optional date, horizon and link. No always-on notification.
- Once a day, at a set time and not on excluded days, the evening ping asks "Got ten minutes for someone today?" with Yes and Not today. Not today costs nothing. Nothing is shown as overdue. When there is a top reason (an owed reply, the reconnect person) the ping names it. There are no extra pings for owed replies.
- Home shows the capture card, "Tonight's pick" (one item, or three by setting), "Coming up" and the open thoughts. Tapping a thought opens the person; editing is a button on the row.
- "Open chat" opens the person's main messenger. On return: "Did you write to Tom?", then the "Nice one" screen (stamps, activity, line for next time, "Planning to meet up?").
- Pick order: birthday today, owed reply, reconnect person, own thoughts and due plans, the gentle rhythm hint last.

**People**

- Classes: Close friends, Now and then, A few times a year; Family is a separate group. "Getting back in touch" is a state on top. Default rhythms 2 weeks, 6 weeks, 3 months, editable; a rhythm only drives a gentle hint.
- The reconnect person has a span (a setting, start a month, from a week to more than a month).
- A person is an initial in a coloured shape with a plant badge for the class. No photos.

**Time**

- Upcoming tab: birthdays for 12 months and dated thoughts. After a date the app asks once "Did it happen?" (Yes, New date, No).
- Undated plans have a horizon: soon (due after about 14 days), later (about 60), when... (never by itself).
- Each person has a timeline: upcoming on top, history below. Contact is recorded in both directions; incoming automatically through the optional listener, or by the "They wrote" and "They called" buttons.
- Birthdays show only on the day. Two pings: evening, and 23:00 if not congratulated. No belated reminders.

**Stamps and streak**

- At most one stamp-earning contact per person per week. Value: class weight (close 1, now and then 2, a few times a year 3, Family 2), +1 getting back in touch, +1 if longer ago than the rhythm. A meet-up doubles; so does gaming, except with close friends (counts 1). Weights and card sizes are editable.
- Treats have their own stamp numbers; twelve default treats ship.
- The streak counts a week when the user was in touch with someone who is not a close friend. Strict mode ends the streak after a week without; Friendly mode only pauses it. "Longest so far" is kept.

**Permissions, Play, updates**

- Contacts (read) and notifications. Notification access is optional, switched on consciously, own Kotlin code, never reads message text. No call-log permission.
- The app shows every permission, what it is for, that nothing goes to a server, and that it works without it.
- The in-app update is an opt-in (first start, a Home card or Settings). Off means no network request at all. It adds INTERNET and REQUEST_INSTALL_PACKAGES and is for GitHub builds only.
- Anything that adds a permission or risks Play is discussed first.

**Look**

- Dark first, light too, plus a theme setting. Tabs: Home, Upcoming, People, Progress; settings from the gear on Home.
- Own colourful icons, drawn to the icon style guide. App icon: the K. draft.

## 4. Milestones

What was built is in [04-architecture.md](04-architecture.md); decisions are in 02-design.md §8; what to try is in [05-test-list.md](05-test-list.md). Milestone table: 02-design.md §5.

- **M0, setup and risk checks:** done, not released. All five phone checks passed (§8 rows of 2026-11-15). The throwaway code is in git history ("Dev: Add throwaway phone checks for M0").
- **M1, People:** done, in 0.1.0. People tab, person page, contacts import, "Open chat". Tried by the developer. Not confirmed: "Open chat" lands in the right chat from the final code.
- **M2, Capture:** done, in 0.2.0. Capture card, open thoughts, schema 2. Tried: "all worked".
- **M3, Evening question and open items:** done, in 0.2.0. Schema 3, the evening notification, Tonight's pick, "Did you write?", "Nice one". The notification itself was not tried on the phone.
- **M4, Birthdays:** done, in 0.3.0. Birthday pick, two pings, own birthday. Phone checks open (test list).
- **M5, Upcoming and plans:** built, in 0.4.0, untried. Dates, horizons, Upcoming tab, "Did it happen?".
- **M6, Friend timeline:** built, in 0.4.0, untried. Timeline, "They wrote" and "They called". Whether the small arrows show on the phone is open.
- **M7, Owed replies and incoming contact:** built, in 0.5.0 (with schema 4), untried. Optional Kotlin listener (WhatsApp, Telegram, Signal, Discord). No Kotlin tests. Group detection unsure for Telegram and Discord.
- **M8, Rhythm and reconnect:** built, in 0.5.0, untried. Rhythms, hint, reconnect person.
- **M9, Stamps and treats:** built, in 0.5.0, untried. Stamp rule, Progress tab, treats. How the rule feels over weeks is open.
- **M10, Ideas and sharing in:** built, in 0.6.0, untried. Ideas per person, share into the app (own Kotlin). Possible issue: with `singleTop` a share from Chrome may open a second Kept; if so, try `singleTask`.

**After M10** (in 0.7.0, untried on a phone)

- Review changes: tap a thought opens the person; "Did it happen?" third button; "Planning to meet up?"; reconnect span; streak rule with Strict and Friendly; stamp weights (Family 2, gaming with close friends 1).
- First-start flow (contacts, class per name, notifications, update choice) and the permissions page.
- Refresh from contacts, per person and for everyone. "About and licences" row.
- The K. launcher icon. Debug builds as the separate app "Kept. debug".
- The in-app update from GitHub releases, with a "What's new" popup. Not run against a real newer release yet (unverified).
- The evening ping names its reason (an owed reply, else the reconnect person); 21 days are scheduled ahead with predicted texts.

**Left before 1.0.0** (the developer's call)

- Work through [05-test-list.md](05-test-list.md) on the phone; Claude fixes what comes up.
- Review of the German texts (written by subagents).
- The light theme on a phone.
- Open questions (section 5).
- Releases take the next number each time (the next after 0.9.1 is 0.9.2).

**Planned, decided, not built** (to be built in its own session)

- **Log a contact that already happened** (the developer, 2026-11-18, 02-design.md §8): one shared sheet (what: wrote, called, met, played; when: today, yesterday or a date; optional activity and next-time line; Save leads to "Nice one"), reachable from a "We were in touch" button on the person page beside "They wrote" and "They called", and from an "Already happened" choice on the Home capture card. A back-dated contact earns its week's stamp and counts for the streak. Start with the person-page button.

**Ideas for after 1.0.0**

- Rotating praise and example texts.
- An icon per activity (needs a column and a larger icon set).
- Backup export and import.
- The "two come closer" badge (sketches in `docs/concepts/badge-ideas/`).
- Groups and shared events; quick "do soon" items (02-design.md §6.12); doctor appointments; iOS.
- Excluded hours; a language setting.

## 5. Open questions for the developer

- **Any messenger: decided 2026-11-18 (02-design.md §8), build planned, not started.** The app list is confirmed (02-design.md §8). The two debug-only experiments (shortcut picker, link test) were removed on 2026-11-18 after the tests; they are in git history ("Dev: Add chat shortcut experiment to debug builds"). The WhatsApp shortcut capture is not built. Build plan, one commit per step:
  1. **Chat app catalogue** (`domain/chat_app.dart`): enum `ChatApp` replacing `Messenger`; per app the Android packages, how a bare target becomes a link (template or none), which link hosts belong to it (to recognise links in a contact's Website field), the contact entry MIME type if the app writes one. Pure Dart, unit tests. `chat_link.dart` becomes the resolver for the open order (target, contact entry, phone, main screen).
  2. **Schema 6** (done 2026-11-18, 04-architecture.md): `mainMessenger` becomes `chatApp` (same values for the four old ones), new `chatTarget`, drop `telegramUsername`, `signalLink`, `discordUserId`. Migration test from schema 5 with the drift schema dumps, as for 4 to 5.
  3. **Contact routes** (done 2026-11-18; Signal, Telegram and WhatsApp MIME types seen on the phone, opening not yet tried by the developer) (Kotlin, existing READ_CONTACTS): a channel that lists the linked contact's data rows of known messenger MIME types (row id, MIME type) and its Website entries; Dart maps them to `ChatApp` options. Opening a contact entry: ACTION_VIEW on `content://com.android.contacts/data/<id>` with its MIME type. Looked up fresh at every "Open chat", nothing stored. Unverified on the phone; check first, like the M0 checks.
  4. **Installed filter** (done 2026-11-18): `<queries>` package entries for every app in the list (no permission) and a channel call "which of these packages are installed". `ChatOpener` reports "not installed".
  5. **Icons**: done 2026-11-18. The developer chose them (teams-b, the first linkedin, the pinwheel slack-c); all drafts kept in `docs/concepts/messenger-icons-v1/`.
  6. **Edit page** (done 2026-11-18; the help link follows with step 7): the messenger section becomes "From the contact" options, None, the installed list, and the chat target field with the help line; "chat link" opens the help page. ARB keys EN and DE.
  7. **Help page** (done 2026-11-18, from the developer's tests in 02-design.md §8; the German names of other apps' menu items are unverified) "How to get a chat link": only links confirmed with the link test page.
  8. **Callers**: open_chat, person page, Tonight's pick, chat question, class chooser, reconnect card, couples, demo data move to `ChatApp`; 04-architecture.md and 05-test-list.md updated.
  Before step 7 the developer runs the link test page for the apps they use and sends the report.
- The person page covers the tab bar; the concept shows the bar. Keep? (Claude's choice, not confirmed.)
- Row classes of the database are used as models, as in akai (Claude's choice, not confirmed in the review).
- For a Play release, remove only the notification listener and the in-app update, or more? List in 04-architecture.md.
- Other companies' logos (messenger icons) touch brand rules in a published app. Look at this before a Play release.
- Claude's "not confirmed" rows in 02-design.md §8 for M5 to M10 that the review did not cover. The review covered only the nine points of its own row; the rest stands until overruled.
- The repository is public and 01-research.md describes the developer's own situation (§5, §9.7, §9.8). Mention it once more if the repository gets promoted.

## 6. Not tested yet

Everything that only the developer can check is in [05-test-list.md](05-test-list.md). Not in it:

- The shared emulator from this container.
- Long delays of the evening notification in deep sleep (the M0 test ran on charge; the list has a point for it).
- Signal with a user-name link, Discord with a user ID.
- Missed and outgoing messenger calls, and other messengers' calls (§8, 2026-11-15, not tested).
- Whether cancelling the 23:00 birthday ping from the background isolate works (unverified).

## 7. How to work here

- **Flutter runs in the dev container, not in WSL.** From a Claude session in WSL: find the container with `docker ps` (its image name starts with `vsc-friendsapp`), then `docker exec -u vscode <name> bash -lc 'cd /workspaces/friendsapp && flutter analyze'`. The container only runs while the developer has the folder open in VS Code.
- **Installing on the phone:** from WSL through the Windows adb, by cable or wireless debugging. Build in the container (`flutter build apk --debug --target-platform android-arm64`), copy `build/app/outputs/flutter-apk/app-debug.apk` to `/mnt/c/Windows/Temp/`, then from that folder `cmd.exe /c "adb install -r <file>"`. If `adb devices` is empty, ask the developer to run `adb connect <address shown under Wireless debugging>`. The phone is often nearly full; an install then fails with "not enough space" and the developer has to free about 1 GB. **Debug builds are the separate app `de.gartenpa.kept.debug` ("Kept. debug") and can never replace the release.**
- **Looking at a screen without the phone:** see 04-architecture.md §2.4 (throwaway widget test that writes pictures).
- **Git runs in WSL** in `/home/paga/Projects/friendsapp`. Push works through the Windows Git Credential Manager (set per repository). Push only when the developer asks.
- **Commits:** small, one finished step each, subject with prefix (the hook checks it), short messages. Feature, Bugfix and Improvement subjects are shown to users in the app's "What's new", so write them for users. End each message with the attribution line the session gives.
- **Token use:** keep it low, and keep messages to the developer short. The main session plans, writes the briefs, reviews and decides. Building goes to subagents, the smallest model that keeps the quality: Sonnet for screens and edits with a precise brief, Opus only for work where a mistake is costly (database and migrations, native code), Haiku for mechanical doc edits with the exact text given. One agent per set of files; each brief names what must not be touched and asks for a short report. Check every result yourself: rerun analyze and tests, read the risky parts.
- **Tags are releases.** Every tag is `v<version>` matching pubspec.yaml; pushing it runs the release workflow (signed APK, public GitHub release). No other tags. **No version is ever skipped** (the developer, 2026-11-16): each release is the next number after the last one, whatever milestones it holds; the minor number does not follow the milestone numbers. 1.0.0 is the first real release. The build number after the `+` goes up with every release.
- **Icons:** draw with simple shapes; Sonnet is enough. Never delete drafts the developer has seen.
- **Parallel agents:** run agents in parallel wherever their files do not overlap.
- **Test list:** [05-test-list.md](05-test-list.md) is the list of what only the developer can check. Add points with every change.
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
