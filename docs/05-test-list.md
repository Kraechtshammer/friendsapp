# 05 Test list

Things only the developer can check, on the phone and in daily use. Claude adds points with every milestone and release; the developer ticks them or writes what happened. A point stays until the developer has answered it.

Tests that run by themselves (`flutter analyze`, `flutter test`, the migration tests) are not listed here.

## Before anything else

- [ ] After every update: all people, open thoughts and settings are still there.

## M3, evening question and open items (in 0.2.0)

- [ ] The evening question arrives at about the set time.
- [ ] It does not arrive on an excluded weekday.
- [ ] It still arrives after a restart of the phone without opening the app.
- [ ] It arrives when the phone lay unused for hours (deep sleep).
- [ ] "Not today" with the app closed: the app stays closed.
- [ ] "Yes" with the app closed and with the app open: Home opens at "Tonight's pick".
- [ ] The small sprout icon in the status bar looks right.
- [ ] After refusing the notification permission, Settings shows the calm line and its button opens the right system page.
- [ ] "Open <messenger>" lands in the right chat, then "Did you write to ...?" appears on return.
- [ ] German texts read well (they were written by subagents).

## M4, birthdays (in 0.3.0)

- [ ] On a real birthday: the notification arrives at the evening time, also on an excluded weekday, in addition to the evening question.
- [ ] "Yes" on it with the app closed: the wish is stored (the pick is gone on Home) and no 23:00 notification follows.
- [ ] Without an answer: a second notification arrives at about 23:00.
- [ ] "Open chat" on the notification opens the messenger, and the question follows on return.
- [ ] After midnight the birthday is gone from Home.
- [ ] "Birthdays" shows as its own channel in the app's Android notification settings.
- [ ] Your own birthday: the "Who congratulated you?" card and its toggles.

## M5, Upcoming and plans (in 0.4.0)

- [ ] Capture with a date, with a date and time, with Soon, Later and When...: still quick enough?
- [ ] The system date and time pickers look and behave right in the app's theme.
- [ ] Tap a thought: the edit sheet opens; the keyboard does not cover its fields.
- [ ] Upcoming tab: your real birthdays are all there, in the right order, with the right age.
- [ ] The day after a dated plan: "Did it happen?" appears once on Home; try Yes and No.
- [ ] Is it right that tapping a thought on Home opens the edit sheet instead of the person page?

## M6, friend timeline (in 0.4.0)

- [ ] Person page, scrolled down: the timeline shows your real history since M3 and the next birthday.
- [ ] The small arrows before "You wrote" and "<Name> wrote" show as arrows, not as empty boxes.
- [ ] "They wrote" and "They called": the entry appears, Undo removes it, a second tap the same day says it is already noted.
- [ ] Tap a history entry: edit the note, delete the entry.

## Schema 4 (not released yet)

- [ ] The first install of a build with schema 4: all people, thoughts, history and settings are still there. (Tested automatically row by row, but never run on your phone.)

## M7, incoming messages and owed replies (not released yet)

- [ ] Settings, "Incoming messages": switch on, grant notification access, the state shows "Allowed".
- [ ] A WhatsApp message from one person on your list appears in their timeline as "<Name> wrote", once per day.
- [ ] A message in a WhatsApp group is not recorded.
- [ ] An incoming WhatsApp call shows as "<Name> called"; your own outgoing call is not recorded.
- [ ] The same for Telegram, Signal and Discord, as far as you use them (group detection there is unsure).
- [ ] A person whose name in the messenger differs from the name in Kept: are they still recognised?
- [ ] Two days after an unanswered message: "Still owe ... a reply?" is the pick on Home. Try Open chat and Already answered.
- [ ] Switching the part off stops the recording.
- [ ] Do you miss a notification for owed replies? (There is none, by Claude's choice.)

## Release builds

- [ ] The APK from the GitHub release installs over the debug build or over the last release, and keeps the data. (A debug build and a release build are signed differently; Android may refuse one over the other. Do not uninstall to get around it: that deletes the data. Tell Claude instead.)
- [ ] The notification icon shows in the release build.
