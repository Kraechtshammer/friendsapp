# Handoff

The first thing a new session reads. Rewritten on 2026-11-15 at the end of the design sessions, so that implementation can start in a fresh session. The log of the research and design sessions is in [history-research-and-design.md](history-research-and-design.md).

## 1. Where things stand

- Phase: **implement**. Research closed 2026-11-14, design closed 2026-11-15, both by the developer.
- The app is called **Kept.** with the full stop, which is also the app label; running text may write Kept. Version 0.1.0+1; Claude chooses the steps up to 1.0.0, which is the first real release. App ID `de.gartenpa.kept` (final). The repository and folder are `friendsapp`.
- **M0 is done** (2026-11-15). **M1 (People) is done** (2026-11-16, section 4a). M2 (Capture) is next.
- Everything up to the end of M0 is pushed and CI passed on it. The repository on GitHub is public.

## 2. What to read, and how much

1. [CLAUDE.md](../CLAUDE.md): the working rules. Short.
2. This file.
3. [02-design.md](02-design.md): §3 data, §4 technology, §5 milestones. Section 6 is the long history of how each point was settled; section 3 of this handoff sums up its results, so read §6 only when a detail is needed.
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

## 4. M0: what was done, and what is next

Done:

- Dev container (copied from akai-timetrack). The developer has opened it in VS Code.
- Flutter project: Android only, label "Kept.". In the container `flutter analyze` is clean, the template test passes, debug and release APKs build.
- CI and release workflows, build and install scripts, F5 launch configurations, commit hook. The first CI run on GitHub passed (2026-11-15).
- Packages (2026-11-15): all packages from 02-design.md §4 are in pubspec.yaml (`url_launcher` was removed again after the phone test). `compileSdk` is 37 and core library desugaring is on, as the plugins need. Checked: analyze clean, debug APK builds in the container, and CI passed on GitHub with them (2026-11-15, commit 2528756).
- App skeleton (2026-11-15): layers as in akai-timetrack (`lib/app`, `lib/ui`, `lib/l10n`). `app/theme.dart` holds every colour of the style guide (`KeptColors`, read with `context.kept`) and builds the dark and the light theme. Outfit is bundled as a variable font (`assets/fonts`, OFL licence beside it). Four tabs with empty screens, the gear on Home opens Settings, which has only the theme choice (system, light, dark; kept in memory until the database exists). English and German texts; English is the template. Checked: analyze clean, one widget test passes, and Claude looked at pictures of the Home tab in dark and light, rendered by a throwaway test with the real fonts: title, gear, tab bar and icons with shadows look as intended. Not checked: anything on a phone. Known difference: the pill behind the active tab icon is Flutter's 64 × 32, the style guide says 64 × 36.
- Icons (2026-11-15): the eighteen icons of `gen_v6.py` (sixteen plus WhatsApp and Telegram) are in `assets/icons/`, extracted by script, not retyped. `KeptIcon(KeptIcons.home)` in `ui/kept_icon.dart` shows one with its hard shadow, which is the same picture in black at 30 % placed 2 below, because `flutter_svg` has no drop-shadow filter. The tabs and the gear use them. Checked: analyze, tests, and the five used ones in the rendered pictures. Not checked: the other thirteen, and all of them on a phone. Gift is still to be drawn.
- On the phone (2026-11-15): the debug build runs on the developer's Pixel 7 Pro. Claude saw a screenshot of Home in dark: title, gear, tab bar and icons are right. The developer has not yet said how it looks to them, and light was not looked at on the phone.
- Release signing: the developer created a key for Kept on 2026-11-15 (`android/kept-release.jks`, `android/key.properties`, both git-ignored) and says the three GitHub secrets are entered. Checked by Claude: a local release APK is signed with a non-debug key. Not checked: the secrets and the release workflow, which has never run.
- Phone checks (2026-11-15): all five done with the developer on the Pixel 7 Pro. Results are in 02-design.md §8: no exact-alarm permission needed, buttons work with the app closed, chats open through `android_intent_plus`, the listener sees WhatsApp messages and calls, own drawn messenger icons. The throwaway check screen is removed again; it is in git history (commit "Dev: Add throwaway phone checks for M0") as a starting point for M3 and M7.
- [04-architecture.md](04-architecture.md) is written.

**M0 is done**, as far as Claude can tell; the developer has not said so yet. Left over from it: the Gift, Signal and Discord icons are to be drawn, and the developer has not yet looked at the light theme on the phone.

## 4a. M1, People: done

The data model was settled with the developer on 2026-11-15 (02-design.md §8: messengers, phone contacts, demo database, avatars).

Done:

- Data layer (2026-11-16, built by an Opus subagent, reviewed by Claude): drift database with stored settings and the people table, and the separate demo database with 16 invented people behind a switch in Settings (debug builds only). See 04-architecture.md §2. Checked: analyze clean, 25 tests pass, debug APK builds. Not checked: anything on the phone, including the demo switch and the deletion of the demo file.

Next, in this order:

1. Done (2026-11-16, Opus subagent, reviewed by Claude): People tab and the top of the person page, read-only, with the avatar, card, tag and button widgets. Checked: analyze, 30 tests, and rendered pictures of both screens in dark with the demo people. Not checked: light by eye, and the German texts by the developer ("Eng befreundet", "Wieder in Kontakt kommen", "Kommt bald").
2. Done (2026-11-16): the class badge is a growing plant (02-design.md §8). `Avatar(classBadge: true)` shows it; the People tab shows the same icons beside its group headings. A throwaway switch under "Development" in Settings (`badgePreview` in `ui/widgets/avatar.dart`) puts the badge on the People tab so the developer can see it; remove it once Home or Upcoming shows people.
3. Done (2026-11-16, Sonnet subagent): add and edit a person (`lib/ui/people/edit_person_screen.dart`): name, class, "getting back in touch", main messenger, handles, birthday, notes, avatar shape and colour when editing, and removing a person after a confirmation. Opened by the "+" on the People tab and the pencil on the person page. Checked: analyze, 35 tests, debug APK builds. Not checked: Claude did not look at the screen, neither in a picture nor on the phone.
4. Done (2026-11-16, Sonnet subagent): import from the phone's contacts (`lib/ui/people/import_contacts_screen.dart`, `lib/platform/contacts.dart`): pick contacts, then set the class per person and one main messenger for all. Name, first phone number (normalised, German country code assumed for numbers starting with 0) and birthday are copied. Opened from the "+" on the People tab ("From your contacts" or "By hand") and from the empty People tab. There is no separate first-start flow; the empty People tab is the first start (Claude's choice). `READ_CONTACTS` is in the manifest. Checked: analyze, 42 tests with a fake contact source, debug APK builds. Not checked: the real permission dialog and real contacts on the phone.
5. Done (2026-11-16, Sonnet subagent): the Signal, Discord and Gift icons are drawn (Claude looked at them rendered on both grounds), and "Open <messenger>" on the person page opens the chat (`domain/chat_link.dart`, `platform/chat_opener.dart`, `android_intent_plus`). Without a usable handle, or if the link cannot be opened, it opens the messenger itself. Checked: analyze, 47 tests with a fake opener. Not checked: opening real chats from this code on the phone.

The developer tried the People tab, add, edit and the contact import on the phone on 2026-11-16: "all worked well". **M1 is done** apart from the phone check of "Open chat". Next: **M2, Capture** (02-design.md §2.1 and §5).

Phone numbers are stored with a leading plus; links such as `wa.me` need the digits only.

## 5. Open questions for the developer

- None new. Settled on 2026-11-15 (02-design.md §8): the name is "Kept.", the version starts at 0.1.0, and development builds get demo data. The demo data is built in M1, when there is a people table to fill.
- The repository is public and 01-research.md describes the developer's own situation (§5, §9.7, §9.8). The developer was told before the first push and pushed. Mention it once more if the repository gets promoted.

## 6. Not tested yet

- The shared emulator from this container (volume and device are akai-timetrack's).
- The phone connection from this container. On 2026-11-15 the container saw no phone: an adb server was running on Windows, but listening on 127.0.0.1 only, so not started by `start-adb-server.cmd`. The app was installed from WSL through the Windows adb instead (copy the APK to a Windows folder, then `cmd.exe /c "adb install -r <apk>"`). F5 with hot reload needs the script.
- The release workflow on GitHub.

## 7. How to work here

- **Flutter runs in the dev container, not in WSL.** From a Claude session in WSL: find the container with `docker ps` (its image name starts with `vsc-friendsapp`), then `docker exec -u vscode <name> bash -lc 'cd /workspaces/friendsapp && flutter analyze'`. The container only runs while the developer has the folder open in VS Code.
- **Git runs in WSL** in `/home/paga/Projects/friendsapp`. Push works through the Windows Git Credential Manager (set per repository). Push only when the developer asks.
- **Commits:** small, one finished step each, subject with prefix (the hook checks it), short messages. End each message with the attribution line the session gives.
- **Token use:** keep it low. Hand bulky or mechanical work to Haiku or Sonnet subagents with a narrow brief and check their results. Never let two agents edit the same files.
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
