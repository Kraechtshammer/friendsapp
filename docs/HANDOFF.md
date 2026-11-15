# Handoff

The first thing a new session reads. Rewritten on 2026-11-15 at the end of the design sessions, so that implementation can start in a fresh session. The log of the research and design sessions is in [history-research-and-design.md](history-research-and-design.md).

## 1. Where things stand

- Phase: **implement**. Research closed 2026-11-14, design closed 2026-11-15, both by the developer.
- The app is called **Kept.** with the full stop, which is also the app label; running text may write Kept. Version 0.1.0+1; Claude chooses the steps up to 1.0.0, which is the first real release. App ID `de.gartenpa.kept` (final). The repository and folder are `friendsapp`.
- **M0 has started.** The app skeleton stands: theme, four empty tabs, settings with a theme choice. No feature of Kept is built.
- Everything is committed and pushed. The repository on GitHub is public.

## 2. What to read, and how much

1. [CLAUDE.md](../CLAUDE.md): the working rules. Short.
2. This file.
3. [02-design.md](02-design.md): §3 data, §4 technology, §5 milestones. Section 6 is the long history of how each point was settled; section 3 of this handoff sums up its results, so read §6 only when a detail is needed.
4. [style/ui-style.md](style/ui-style.md) and [style/icon-style.md](style/icon-style.md) before building any screen.
5. [03-dev-setup.md](03-dev-setup.md) for the container, phone, emulator, CI and releases.
6. For how code is laid out, look at `/home/paga/Projects/akai-timetrack/docs/04-architecture.md`. This project follows it unless there is a reason not to. Our own `docs/04-architecture.md` does not exist yet.

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

## 4. M0: what is done and what is next

Done:

- Dev container (copied from akai-timetrack). The developer has opened it in VS Code.
- Flutter project: Android only, label "Kept". In the container `flutter analyze` is clean, the template test passes, debug and release APKs build.
- CI and release workflows, build and install scripts, F5 launch configurations, commit hook. The first CI run on GitHub passed (2026-11-15).
- Packages (2026-11-15): all packages from 02-design.md §4 are in pubspec.yaml, both `url_launcher` and `android_intent_plus` until the phone test picks one. `compileSdk` is 37 and core library desugaring is on, as the plugins need. Checked: analyze clean, debug APK builds in the container. Not checked: CI with the new packages.
- App skeleton (2026-11-15): layers as in akai-timetrack (`lib/app`, `lib/ui`, `lib/l10n`). `app/theme.dart` holds every colour of the style guide (`KeptColors`, read with `context.kept`) and builds the dark and the light theme. Outfit is bundled as a variable font (`assets/fonts`, OFL licence beside it). Four tabs with empty screens, the gear on Home opens Settings, which has only the theme choice (system, light, dark; kept in memory until the database exists). English and German texts; English is the template. Checked: analyze clean, one widget test passes. Not checked: how it looks, on a phone or anywhere else.
- Icons (2026-11-15): the eighteen icons of `gen_v6.py` (sixteen plus WhatsApp and Telegram) are in `assets/icons/`, extracted by script, not retyped. `KeptIcon(KeptIcons.home)` in `ui/kept_icon.dart` shows one with its hard shadow, which is the same picture in black at 30 % placed 2 below, because `flutter_svg` has no drop-shadow filter. The tabs and the gear use them. Checked: analyze, tests. Not checked: how they render on a phone. Gift is still to be drawn.
- Release signing: the developer created a key for Kept on 2026-11-15 (`android/kept-release.jks`, `android/key.properties`, both git-ignored) and says the three GitHub secrets are entered. Checked by Claude: a local release APK is signed with a non-debug key. Not checked: the secrets and the release workflow, which has never run.

Next, in this order. One small commit per step.

1. Done: packages.
2. Done: app skeleton.
3. Done: icons, except Gift, which is still to be drawn.
4. Run it on the developer's phone. This needs the developer.
5. Phone checks, each as a small throwaway screen or debug action, with the developer:
   - a scheduled notification arrives close to its time, also after a restart, without the exact-alarm permission;
   - notification buttons work while the app is closed;
   - chats open in WhatsApp, Telegram, Signal and Discord; this decides between `url_launcher` and `android_intent_plus`;
   - the notification listener sees an incoming WhatsApp message and a WhatsApp call notification;
   - the installed messenger's app icon can be read (needs a `<queries>` entry, no permission; unverified).
6. Write `docs/04-architecture.md` once the structure stands, and record the results of the checks in 02-design.md §8.

## 5. Open questions for the developer

- None new. Settled on 2026-11-15 (02-design.md §8): the name is "Kept.", the version starts at 0.1.0, and development builds get demo data. The demo data is built in M1, when there is a people table to fill.
- The repository is public and 01-research.md describes the developer's own situation (§5, §9.7, §9.8). The developer was told before the first push and pushed. Mention it once more if the repository gets promoted.

## 6. Not tested yet

- The shared emulator from this container (volume and device are akai-timetrack's).
- The phone connection from this container.
- The release workflow on GitHub.
- Nothing of the look has been built in Flutter or seen on a phone.

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
