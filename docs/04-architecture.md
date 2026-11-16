# Architecture and code style

Status: first written on 2026-11-15, at the end of M0. The app is a skeleton: four empty tabs, a settings screen with a theme choice, the theme, the icons and the texts. §1 describes what exists, checked against the code. §2 describes the data layer added in M1 and what is still planned. Behaviour lives in [02-design.md](02-design.md), the look in [style/ui-style.md](style/ui-style.md). The layering follows akai-timetrack (`/home/paga/Projects/akai-timetrack/docs/04-architecture.md`, same developer) unless stated otherwise. Update this file in the same step as every structural change.

## 1. What exists now

About 760 lines of Dart in `lib/`, of which 290 are generated localisation files. Two test files.

### 1.1 Layers present

| Folder | Holds | May import |
|---|---|---|
| `app/` | `KeptApp`, the theme, Riverpod providers | `ui`, `l10n` |
| `ui/` | The tab shell, one folder per tab, `common.dart`, `kept_icon.dart`, `material.dart` | `app`, `l10n` |
| `l10n/` | ARB files and the generated `AppLocalizations` | nothing of ours |

Imports that go against a strict order: `app/app.dart` imports `ui/home_shell.dart` (normal for the app root), and `ui/common.dart` imports `app/theme.dart` for `KeptColors`.

`main()` calls `WidgetsFlutterBinding.ensureInitialized()` and `runApp(ProviderScope(child: KeptApp()))`. Nothing else starts up yet: no database, no notifications.

### 1.2 App root

`KeptApp` (`app/app.dart`) is a `ConsumerWidget` that builds a `MaterialApp`:

- `theme` and `darkTheme` come from `buildTheme(Brightness)`; `themeMode` comes from `themeModeProvider`.
- `builder` wraps the app in `M3ETheme`, made with `M3EThemeData.fromMaterial`, so the Material 3 Expressive widgets take colours and type from the Material theme.
- Localisation delegates are `AppLocalizations.delegate` and `GlobalMaterialLocalizations.delegates`. `onGenerateTitle` uses the text `appTitle` ("Kept.").
- `home` is `HomeShell`. There is no router package; settings is a pushed `MaterialPageRoute`.

### 1.3 Theme (`app/theme.dart`)

- **`KeptColors`** is a `ThemeExtension` with the colours Material's `ColorScheme` has no place for: `ground`, `surface`, `surfaceHigh`, `greyEdge`, `shadow`, `text`, `muted`, `line`, and six `Tone`s (sun, mint, lilac, pink, sky, coral). A `Tone` is a container colour plus the text colour that goes on it. The accents (`coral`, `sun`, `mint`, `lilac`, `sky`, `pink`, `onAccent`) are static constants, the same in both themes. `KeptColors.dark` and `KeptColors.light` are the two fixed sets. Read them with `context.kept`.
- **`buildTheme(Brightness)`** builds a `ColorScheme` from these tokens:

| Style guide token | Material role |
|---|---|
| coral | `primary`; its tone is `primaryContainer` |
| sun | `secondary`; its tone is `secondaryContainer` |
| mint | `tertiary`; its tone is `tertiaryContainer` |
| ground | `surface`, `surfaceContainerLowest`, scaffold background |
| surface | `surfaceContainerLow`, `surfaceContainer` |
| surfaceHigh | `surfaceContainerHigh`, `surfaceContainerHighest` |
| text, muted | `onSurface`, `onSurfaceVariant` |
| line | `outline`, `outlineVariant` |
| shadow | `shadow` |
| coral tone | `error` and `onError`, because nothing is shown as a warning (ui-style.md §2.7) |

  Lilac, sky and pink have no Material role; they are only in `KeptColors`.
- **Type:** Roboto (Android's own font) is the default. `outfit(size, weight, {color})` returns an Outfit `TextStyle`. `assets/fonts/Outfit.ttf` is a variable font, so the weight is also set through `FontVariation.weight`. The text theme maps `displayLarge` (68, big number), `headlineLarge` (30, screen title), `titleLarge` (21, card title), `labelLarge` (17, button) and `labelMedium` (13, section label, letter spacing 0.08 em) to Outfit. Body text stays Roboto at 16 and 14 (`bodyMedium` is muted).
- **Component themes** set so far: app bar, icon buttons (`StyleVariant.material3Expressive`), navigation bar (height 76, surface colour, surface-high stadium indicator, 12 px labels, 26 px icons) and snack bars (floating).
- Theme mode lives in `themeModeProvider` (`app/providers.dart`), a `Notifier<ThemeMode>` that starts at `ThemeMode.system`.

### 1.4 UI

- **`ui/material.dart`** is the single import for UI files. It re-exports `material_ui` and `material_3_expressive` and hides the name clash (`CornerRounding`, `RoundedPolygon`; the Expressive ones win). UI files do not import `package:flutter/material.dart`.
- **`ui/common.dart`:** the `ContextHelpers` extension on `BuildContext` (`l10n`, `colors`, `kept`, `text`); `TabPage` (screen title, optional action buttons, content; padding 16 / 22 / 16 / 0); `EmptyHint` (the text "Nothing here yet.", for screens not built yet).
- **`ui/home_shell.dart`:** `HomeShell` is a `StatefulWidget` that holds the tab index. The body is an `IndexedStack` of Home, Upcoming, People and Progress. The bottom bar is a `NavigationBar` with four destinations. The tab folders `ui/home`, `ui/upcoming`, `ui/people` and `ui/progress` each hold one screen, still a `TabPage` with an `EmptyHint`. Home has the gear that opens `ui/settings/settings_screen.dart`.
- **Settings** has one control: a `SegmentedButton<ThemeMode>` (System, Light, Dark) bound to `themeModeProvider`.
- **Icons** (`ui/kept_icon.dart`): the enum `KeptIcons` has one value per SVG file in `assets/icons/` (18 now) and `asset` gives the path. `KeptIcon(icon, size: 24, shadow: true)` shows it with the small shadow from ui-style.md §5. `flutter_svg` has no drop-shadow filter, so the shadow is a second copy of the same SVG, tinted black at 30 % with a `ColorFilter`, drawn 2 px lower in a `Stack`. New icons follow [style/icon-style.md](style/icon-style.md): add the file and the enum value together; a test checks that they match.

### 1.5 Localisation

- `l10n.yaml`: template `lib/l10n/app_en.arb`, output `app_localizations.dart`, `nullable-getter: false`. `pubspec.yaml` has `flutter: generate: true`.
- English is the template; German is `app_de.arb`. Today there are 12 keys (title, four tabs, settings, theme labels, empty hint).
- The generated `app_localizations*.dart` files are committed. After changing an ARB file, run the generator and commit its output with the change.
- Screens read texts with `context.l10n`. No text is written in a widget.

### 1.6 Riverpod

Used for one thing: the theme mode, in memory. There are no stream providers yet. Screens that read it are `ConsumerWidget`s.

### 1.7 Tests

- `test/widget_test.dart`: pumps `KeptApp`, checks the four tab labels and five `KeptIcon`s, switches tabs, opens settings from the gear, and switches to Dark and back to Light, checking `KeptColors` after each.
- `test/icons_test.dart`: the files in `assets/icons/` and the `KeptIcons` values match.

### 1.8 Android

- App ID and namespace: `de.gartenpa.kept`. `compileSdk` is 37. `minSdk` and `targetSdk` come from Flutter.
- Core library desugaring is on (`desugar_jdk_libs` 2.1.4), as `flutter_local_notifications` needs it.
- Permissions in the manifest: `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED`. The manifest also holds the three receivers of `flutter_local_notifications` (scheduled, after a restart, buttons) and `<queries>` entries for the messenger packages, so "Open chat" can see them. Both are ready for M3 and tested on the phone (02-design.md §8); no Dart code uses them yet.
- Version is 0.1.0+1.
- Dependencies are in `pubspec.yaml`. Several (drift, notifications, contacts, `android_intent_plus`, `quick_actions`, `uuid`, `permission_handler`) are declared but not used by the code yet.

## 2. Data and domain (since M1)

Written on 2026-11-16 with the first data code. §1 above describes the state at the end of M0; where it says there is no database and the theme mode is in memory, this section is right.

### 2.1 Layers

| Folder | Holds | May import |
|---|---|---|
| `domain/` | `person.dart` (the enums `Closeness`, `Messenger`, `AvatarShape`, `AvatarColor`, no drift import), `avatar_pick.dart` (which shape and colour a new person gets), `demo_data.dart` (the invented people) | `data` for the row classes |
| `data/` | `database.dart` (drift tables `Settings` and `People`, schema version 1), `database_connection.dart` (opens the files), `app_settings.dart`, `settings_repository.dart`, `people_repository.dart` | `domain` for the enums |
| `app/services.dart` | `AppServices`: created in `main()`, holds the databases and repositories, injected through `servicesProvider` | `data`, `domain` |

- **Row classes are the models**, as in akai: `Person` is drift's generated row class. Decided by Claude following akai; the developer has not objected. Enums are stored as text by name.
- **Settings** are a key and value table, read as one immutable `AppSettings` (`themeMode`, `demoMode`) through `settingsProvider`. `ref.settings` gives the current value or the defaults.
- **People:** `PeopleRepository` gives streams (`watchAll`, `watch`) and `add`, `update`, `delete`. `add` makes the UUID and picks the avatar. Screens read `peopleProvider` and `personProvider(id)` and write through `peopleRepositoryProvider`.
- **Generated code** (`database.g.dart`) is committed. After changing a table run `dart run build_runner build --delete-conflicting-outputs`. `drift_schemas/` holds a snapshot of schema version 1 for later migration tests; there are no migrations yet.

- **Intentions (M2):** table `intentions` (schema version 2) with `IntentionsRepository` and the providers `openIntentionsProvider` and `personIntentionsProvider(id)`. Enums are in `domain/intention.dart`. The columns `date`, `horizon`, `condition` and `link` are there for later milestones. Deleting a person deletes their intentions; foreign keys are switched on in `beforeOpen`.
- **Contact events and day answers (M3):** tables `contact_events` and `day_answers` (schema version 3) with `ContactEventsRepository` and `DayAnswersRepository`. Enums and the mapping from an intention's kind to a contact's kind and direction are in `domain/contact_event.dart`. `completeIntention` marks an intention done and stores the linked event in one transaction. Deleting a person deletes their events; deleting an intention keeps the event and clears the link. No screen uses them yet.
- **Evening question (M3):** `domain/evening_question.dart` works out the plan (which weekdays, what time, off) as pure functions. `platform/notifications.dart` wraps `flutter_local_notifications` behind a provider (tests use `test/fake_notifications.dart`): one weekly repeating, inexact notification per allowed weekday, scheduled again on every start and settings change. "Not today" runs in a background isolate (`onEveningResponseInBackground`): it opens the real database with `openAppDatabase()`, writes the day answer and closes; it never opens the demo database. "Yes" opens Home scrolled to the open thoughts. Evening time, excluded weekdays and the on/off switch are keys in the settings table.
- **Open item and "Did you write?" (M3):** `domain/pick_order.dart` (`intentionPicks`: open intentions, oldest first, one per person; later sources join here). `ui/home/tonights_pick.dart` shows one pick or three (`OpenItemsMode` in the settings). `ui/home/open_chat.dart` opens the messenger and queues a `ChatQuestion` in `pendingChatQuestionProvider`; `HomeShell` listens to the app lifecycle and shows `chat_question_screen.dart` on return. Yes ends in the "Nice one" screen through the shared code in `nice_one_screen.dart`.
- **Birthdays (M4):** no table of their own. `domain/birthdays.dart` works out who has their birthday on a day (29 February counts on 28 February in other years), the age, and whether the user congratulated today (a contact event `birthdayWish` `byUser` dated today). `domain/pick_order.dart` returns `BirthdayPick` before `IntentionPick`. `domain/birthday_notifications.dart` plans two notifications per person on the day (evening time and 23:00); ids are `0x10000000 + 2 * hash(personId) + (late ? 1 : 0)`, apart from the evening question's 101 to 107; the payload is `birthday:<id>:<date>:<evening|late>`. The background entry is now `onResponseInBackground` for both kinds: a birthday "Yes" stores the wish once and cancels the late notification. `ui/home/congratulated_screen.dart` records who congratulated the user (`birthdayWish` `byThem`); the user's own birthday is a settings key.
- **Upcoming and plans (M5):** no schema change. `When` in `domain/intention.dart` wraps the three columns (a date, where local midnight means "no time"; or a horizon with an optional condition). `domain/timeline.dart` builds the Upcoming list (birthdays and dated thoughts for the next 12 months, grouped by week and month) as a pure function. `domain/plans.dart` holds the rules: a dated thought counts as passed when its day is over (three hours after a set time), and an undated plan is due as a pick 14 days (Soon) or 60 days (Later) after `createdAt`. `pick_order.dart` adds `PlanPick`. UI: `widgets/when_picker.dart`, `home/thought_sheet.dart` (edit a thought), `home/coming_up.dart`, `home/did_it_happen.dart`, `upcoming/upcoming_screen.dart`.
- **Friend timeline (M6):** not stored. `domain/person_timeline.dart` (`personTimeline`) builds it from the person's contact events, open thoughts and birthday, and from the user's own birthday wishes. `ui/people/person_timeline_view.dart` shows it on the person page; `incoming_buttons.dart` ("They wrote", "They called": one entry per person, kind and day, `addByThemOnce`) and `contact_entry_sheet.dart` (edit activity and note, delete). `replaceAll` on the repositories is for the demo database only.
- **Schema 4 (for M7 to M10):** one step that only adds: `people.replyClearedAt`, `contact_events.activityIcon`, and the tables `treats`, `stamps` (its links to person, event and treat are set to null on delete, so the count never shrinks) and `ideas` (deleted with the person). Enums in `domain/treat.dart` and `domain/idea.dart`. Repositories come with the milestones that use them.
- **Incoming contact and owed replies (M7), an optional part, off by default:** Kotlin `KeptNotificationListener.kt` (the listener and a small store in SharedPreferences and a queue file), `IncomingRules.kt` (pure rules: which notification is a 1:1 message or a call, name matching, one queue entry per person, kind and day) and `IncomingChannel.kt` (MethodChannel). It reads only the package, time, category, flags, template, title, the group flag and the call type; never the message text; nothing is logged. Dart: `platform/incoming_listener.dart` behind a provider, `app/incoming_sync.dart` (writes the watch list of names, reads the queue on start and resume into contact events with source `listener`), `domain/incoming_contact.dart`, `domain/owed_reply.dart` (owed when the newest incoming message is older than the waiting time, not answered and not cleared through `people.replyClearedAt`). `pick_order.dart` ranks owed replies second. **For a Play build this part must be looked at again (01-research.md Q9); to remove it, delete these files, the manifest service entry, the line in `MainActivity.kt`, the Settings section, the `IncomingSync` calls in `HomeShell` and the two listener providers.**
- **Rhythm and reconnect (M8):** no schema change. `domain/rhythm.dart`: a person's last contact, whether they are due for a hint (own rhythm, else the class's from the settings; none means never), and the one hint pick per day chosen by a rotation seeded with the date. `domain/reconnect_week.dart`: the reconnect person of the week (person id and that week's Monday in the settings), its done state, and the "first exchange" rule (the user's contact and a reply within 60 days). `pick_order.dart` now has all five ranks: birthday, owed reply, reconnect of the week, thoughts and plans, hint. UI: `people/reconnect_card.dart`, `home/back_in_touch_card.dart`, `widgets/rhythm_stepper.dart`.
- **Migrations:** as in akai. After changing a table, raise `schemaVersion`, run `dart run drift_dev make-migrations`, write the step in `database.dart` and extend the test in `test/drift/kept/`. The developer has real data on the phone since 2026-11-16, so every schema change needs a tested step.

### 2.2 Demo database

Two files: `kept.sqlite` (real) and `kept_demo.sqlite`. Settings always come from the real one. People, and later all content, come from the demo one while `demoMode` is on. Switching on refills the demo database from `demoPeople(today)` and the providers move over without a restart. Switching off moves back; the demo file is deleted at the next start. `AppServices.allowDemo` is `kDebugMode`, so a stored `demoMode` does nothing in a release build. The switch is in Settings under "Development", in debug builds only.

### 2.3 Tests

In-memory drift databases. `test/demo_mode_test.dart` shows how to build `AppServices` for a test. In widget tests the database must be closed inside `tester.runAsync` after pumping an empty widget (see the note in `test/widget_test.dart`); closing it under the test clock hangs.

### 2.4 Screens and widgets (M1)

- `ui/widgets/`: the building blocks of ui-style.md §6, one per file: `Avatar` (initial in one of four shapes, drawn as a path so the hard shadow follows it; optional class badge, a growing plant, `classBadge: true`), `KeptCard`, `Tag`, `SectionLabel`, `MainButton`. Hard shadows are a solid offset copy: a `BoxShadow` with blur 0, or the shape's path drawn twice.
- `ui/people/people_screen.dart`: people grouped by class, read from `peopleProvider`. `person_screen.dart`: the tonal header with avatar, name and tags, the "Open <messenger>" button (shows "Coming soon" for now) and the notes card. The person page is pushed on the root navigator, so it covers the tab bar; the concept shows the bar there.
- `ui/people/edit_person_screen.dart`: one form for adding and editing a person. It writes through `peopleRepositoryProvider`. Form widgets it brought: `GreyIconButton`, `choice_chips.dart`, `KeptSwitch`, `KeptTextField`, all in `ui/widgets/`.
- `platform/contacts.dart`: `ContactsSource` with `DeviceContacts` (`flutter_contacts`, read permission only) behind `contactsSourceProvider`, so tests use a fake. `domain/phone_number.dart` normalises numbers. `ui/people/import_contacts_screen.dart` is the two-step import.
- `domain/chat_link.dart` builds the link and package for a person's main messenger; `platform/chat_opener.dart` opens it with `android_intent_plus`, behind `chatOpenerProvider`.
- `ui/home/` (M2): `capture_card.dart` (text, person, kind, Save), `person_picker.dart` (the searchable sheet behind "More"), `open_thoughts.dart` (open intentions). `domain/greeting.dart` picks the greeting from `clockProvider`, which tests fix. `platform/app_shortcuts.dart` wraps `quick_actions` behind `appShortcutsProvider`; the shortcut focuses the capture field through `captureFocusProvider`. `HomeShell` owns the tab index and registers the shortcut.
- `l10n/labels.dart` turns enums into texts and formats birthdays. It imports `ui/kept_icon.dart` for the messenger icon, as akai's does.
- Looking at screens without a phone: a throwaway widget test can load the real fonts (`FontLoader`, Roboto from Flutter's cache and `assets/fonts/Outfit.ttf`), pump the app with in-memory services in demo mode and write pictures with `matchesGoldenFile` and `--update-goldens`. Material icons show as boxes there. Delete the test afterwards.

### 2.5 Planned, not built

| Layer | Will hold |
|---|---|
| `core/` | Time helpers (day keys, calendar arithmetic) |
| `domain/` | The pick order, the stamp rule, rhythms and due dates, as pure functions that take the current time as a parameter |
| `platform/` | Notifications, contacts and birthdays, opening chats with `android_intent_plus`, our own Kotlin notification listener, icon long-press |

## 3. Code style

Taken from the code as it is, and from akai's doc where it applies.

- **Formatting:** `dart format`. Lints: `flutter_lints` only, no extra rules yet. `flutter analyze` should be clean. Akai also enables `unawaited_futures` and a few more; adopt them when the first async code arrives (ask first).
- **Files:** one screen per file, in a folder per tab. Shared widgets go to `ui/common.dart` once a second screen needs them.
- **Widgets:** `StatelessWidget` or `ConsumerWidget` where possible. Parts of a screen are private widget classes, not methods that return widgets. Constructors are `const` where they can be.
- **Imports:** packages first, then our own files with relative paths. UI files import `material.dart`.
- **Colours and type:** never a literal colour or font in a screen. Use `context.kept`, `context.colors` and `context.text`. A literal is allowed only inside `app/theme.dart` and in the icon shadow.
- **Texts:** every visible text is an ARB key, in English and German.
- **Names:** Dart conventions. Providers end in `Provider`. Icon enum values are the file name without `.svg`.
- **Comments:** `///` on public classes and non-obvious code. They say why, in plain English, and point to the docs section (`ui-style.md §5`). Same docs style as in CLAUDE.md.
- **Time:** to be fixed with the first data code. Akai's rules (local `DateTime`, day keys for storage, no `Duration` of days for calendar arithmetic) are the starting point.

## 4. Known weaknesses

Remove an item when it is fixed.

- The navigation indicator pill is 64 x 32 (Material's default); ui-style.md §6 says 64 x 36.
- `KeptColors.lerp` does not blend: it switches at the half-way point. A theme change has no colour animation.
- The contrast of muted text on tonal containers has not been measured (also open in ui-style.md §8).
- Tests: one widget test and one asset test. No test checks the theme mapping or the German texts.
- The light theme has not been looked at on a phone. Only the dark theme was checked.
- Declared dependencies that nothing uses yet add build weight and, for notifications, manifest entries. They match the approved list in 02-design.md §4.
- No error or loading UI exists. That is fine now; decide when the database arrives.
