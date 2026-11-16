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

## Schema 4 (in 0.5.0)

- [ ] The first install of a build with schema 4: all people, thoughts, history and settings are still there. (Tested automatically row by row, but never run on your phone.)

## M7, incoming messages and owed replies (in 0.5.0)

- [ ] Settings, "Incoming messages": switch on, grant notification access, the state shows "Allowed".
- [ ] A WhatsApp message from one person on your list appears in their timeline as "<Name> wrote", once per day.
- [ ] A message in a WhatsApp group is not recorded.
- [ ] An incoming WhatsApp call shows as "<Name> called"; your own outgoing call is not recorded.
- [ ] The same for Telegram, Signal and Discord, as far as you use them (group detection there is unsure).
- [ ] A person whose name in the messenger differs from the name in Kept: are they still recognised?
- [ ] Two days after an unanswered message: "Still owe ... a reply?" is the pick on Home. Try Open chat and Already answered.
- [ ] Switching the part off stops the recording.
- [ ] Do you miss a notification for owed replies? (There is none, by Claude's choice.)

## M8, rhythm and reconnect (in 0.5.0)

- [ ] Settings, "Rhythms": change a class rhythm; give one person an own rhythm on their edit page.
- [ ] Over some evenings: the hint "It's been a while with ..." names different people, never with a number, and feels gentle.
- [ ] People tab: choose a reconnect person for the week; "This week: ..." shows as a pick on Home.
- [ ] After you contacted them, the card shows the calm done state; next Monday it starts empty without a remark.
- [ ] After they answered: the "back in touch" card appears once on Home.
- [ ] Do you miss a notification for the reconnect person of the week? (There is none, by Claude's choice.)

## M9, stamps and treats (in 0.5.0)

- [ ] Progress tab after the first start: stamps for your contacts since M3 are there (the one-time backfill), and twelve treats wait under "My treats".
- [ ] Start a card; a contact (Done or "Did you write?") adds stamps and the "Nice one" screen shows them.
- [ ] A second contact with the same person in the same week adds no stamp, and the screen says nothing about it.
- [ ] A full card: the treat becomes yours, "Enjoyed" works, extra stamps carry over.
- [ ] Add a treat of your own, change its stamp number, reorder, delete.
- [ ] Over some weeks: do daily chats with close friends fill cards too fast or too slowly? Rebalance in Settings, "Stamps".
- [ ] Is "weeks in a row" the right wording for a number that counts every week with contact?

## M10, ideas and sharing in (in 0.6.0)

- [ ] Person page, "Ideas": add one of each kind, edit, tick off, delete.
- [ ] Share a link from the browser into Kept, once with Kept closed and once with it open: the "Keep this for..." sheet appears with the link. Does a second Kept window appear inside the browser?
- [ ] Share a photo: save it as an idea, then tap the thumbnail. Share another and cancel.
- [ ] Tap a link on an idea or a thought: it opens in the browser.
- [ ] The pick on Home shows "Idea: ..." for a person who has ideas.

## Review changes, first start, permissions (not released yet)

- [ ] Home: tapping a thought opens the person; the three-dot button opens the edit sheet; nothing is crowded.
- [ ] "Did it happen?": Yes, New date and No each do the right thing.
- [ ] "Nice one" screen: "Planning to meet up?" saves a meet plan.
- [ ] People tab: the reconnect card says "This month: ..." and the span can be changed in Settings.
- [ ] Progress: the streak counts weeks beyond close friends; try Strict and Friendly in Settings.
- [ ] Settings, Stamps: Family shows 2 (the one-time fix), gaming with close friends 1.
- [ ] The birthday pick card: "Congratulated" is fully readable.
- [ ] A fresh install (the release, or "Kept. debug"): the first-start flow runs; every page can be skipped; nothing is switched on that you did not choose.
- [ ] Settings, "Permissions and privacy": every card shows the right state and its button or switch works.
- [ ] Edit person: "Refresh from contact" shows old and new; Settings: refresh for everyone, accept one, skip one.
- [ ] Settings, "About and licences" opens the licence page with the version.
- [ ] The app icon is the K. on the launcher, also as a themed icon if you use those.

## In-app update (not released yet)

A real update needs two release-signed builds: install one release, then a newer release gets published.

- [ ] With the check off: no popup, and Settings says the check is off.
- [ ] Switch it on (first start page, Home card or Settings): after the next start the popup for a newer version comes once.
- [ ] The download shows progress.
- [ ] Android asks to allow installs from Kept.; after coming back the update carries on by itself.
- [ ] Cancel Android's install dialog, then retry: no second download.
- [ ] The update installs and your data is still there.
- [ ] "What's new" shows once after the update.
- [ ] "Releases on GitHub" in Settings opens the browser.
- [ ] A "Kept. debug" build does not try to replace the release.

## Release builds

- [ ] Uninstall the old debug build that still carries the release's name (your decision of 2026-11-16: start fresh), then install the APK from the GitHub release. From then on debug builds install beside it as "Kept. debug".
- [ ] The notification icon shows in the release build.
