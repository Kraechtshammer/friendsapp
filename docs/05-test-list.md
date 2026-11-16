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

## Release builds

- [ ] The APK from the GitHub release installs over the debug build or over the last release, and keeps the data. (A debug build and a release build are signed differently; Android may refuse one over the other. Do not uninstall to get around it: that deletes the data. Tell Claude instead.)
- [ ] The notification icon shows in the release build.
