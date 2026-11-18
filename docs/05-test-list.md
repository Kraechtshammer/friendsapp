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

## Review changes, first start, permissions (in 0.7.0)

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

## Evening ping with a reason (in 0.7.0)

- [ ] After updating: only one evening notification on the first evening, not two.
- [ ] With an owed reply: the title asks "Still owe ... a reply?". With a reconnect person and no owed reply: "This month: ... Got ten minutes?". Otherwise the general question.
- [ ] Yes still opens Home at the pick; Not today still closes it without opening the app.
- [ ] After a restart of the phone the evening notification still comes.
- [ ] Change the evening time to earlier than now: one notification may still come at the old time that day (known).

## In-app update (in 0.7.0)

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

## Release builds (listener build since 0.8.0)

- [ ] `kept-<v>.apk` from the GitHub release installs from the browser without the Play Protect block, and shows nothing about incoming messages.
- [ ] `kept-<v>-listener.apk` installed over adb: incoming messages work as before (the M7 points).
- [ ] On the listener build, the in-app update installs the next `-listener` APK (not blocked by Play Protect, the listener still works afterwards).

- [ ] Uninstall the old debug build that still carries the release's name (your decision of 2026-11-16: start fresh), then install the APK from the GitHub release. From then on debug builds install beside it as "Kept. debug".
- [ ] The notification icon shows in the release build.

## Settings as categories (in 0.9.0)

- [ ] Settings shows eight rows (nine in a debug build), each with its icon and one line; every row opens its own page and Back returns to the list.
- [ ] Changes on the pages still work and stick: evening time and days, rhythms, stamp values, theme (Look), your birthday.
- [ ] When an update is found, the "App update" row says so, and tapping it opens the update page.

## Language and back gesture (in 0.9.0)

- [ ] Settings, Look, Language: switch System, English, Deutsch; all texts change at once and the choice survives a restart.
- [ ] Android System settings > Apps > Kept. > Language lists English and Deutsch. (This is separate from the in-app setting.)
- [ ] Swipe back slowly from the screen edge on a settings page: the page peeks away and the one below shows; release to cancel or finish.

## Share a photo as a picture (in 0.9.0)

- [ ] In Immich, open a photo of a friend, Share, Kept.: the screen "What's this picture for?" shows the photo big, with "Use as someone's picture" first.
- [ ] The same from Google Photos (and one more gallery if you have it).
- [ ] "Keep as an idea" still opens "Keep this for..." and saves the idea as before; next time that choice is first.
- [ ] The list of people starts with those without a picture, then the rest A to Z, with a tick on those who have one; search finds a name; the keyboard does not pop up by itself.
- [ ] Cropping feels smooth when dragging and pinching (also on 120 Hz); the photo never leaves the frame empty; double tap zooms in and out.
- [ ] The frame has the person's avatar shape, and the picture on their page has that shape too and is sharp.
- [ ] A photo taken upright and one taken sideways (EXIF) both end up with the part you framed, the right way up.
- [ ] A 50 MP photo opens in the crop without a long wait or a crash.
- [ ] Replacing a picture works; the old one is gone (storage does not grow).
- [ ] "Done" on the last screen returns to the gallery you came from (and Back does the same).
- [ ] Doing five in a row is quick: share, tap person, Use picture, Done.
- [ ] The tip card at the bottom of Settings > Friends and the line on the last first-start page read well.

## Names and pictures (in 0.9.0)

- [ ] After installing over the old build: all 54 people, thoughts, events and settings are still there (schema 5 migration), and the app opens without a delay.
- [ ] People who share a first name show as "Max M" and "Max F" on Home, Upcoming, the People tab and in notifications; a nickname replaces the name everywhere; the person page shows the short name large and the full name small under it. The contact lists and the edit page still show full names.
- [ ] Edit page: add a nickname, save, and see it on the People tab; empty it, save, and the first name is back.
- [ ] Edit page: "Choose picture" opens the gallery and the crop, the picture shows at once on the edit page and the People tab; "From contact" shows only for a linked contact that has a photo; "Remove picture" brings the initial back. The hint line reads well.
- [ ] People tab, first visit after the update: the card "Add pictures from your contacts?" shows once; "Add" fills the pictures of the contacts that have one and says how many; "Not now" hides it for good; it does not come back after a restart.
- [ ] Importing a new contact takes their photo without asking; "Refresh from contact" offers the picture only for a person who has none.
- [ ] Pictures look sharp on the People tab, the person page and Home, in every avatar shape, with the plant badge on top.
- [ ] The People tab scrolls smoothly with 54 people and pictures (also on 120 Hz); no avatar flashes its initial while scrolling.
- [ ] Delete a person who has a picture; after a restart the app's storage did not keep the file (check Settings > Apps > Kept. > Storage if you want).

## Couples (in 0.9.1)

- [ ] Edit a person, "Link a partner", pick the partner: the row shows their face and "Unlink". Nothing about couples shows anywhere before two people are linked.
- [ ] People tab: the two show once as "Anna & Tom" with both faces overlapping (also with pictures), in the class of the closer one. Tap it: the couple page opens; tap one face: their own page.
- [ ] Capture a thought: "Anna & Tom" is a choice beside the people (also under "More"); it saves as meet by default and shows on Home, under Coming up when dated, on the Upcoming tab, and on both person pages with "with Tom".
- [ ] Couple page "We met": Nice one shows both faces and a stamp for each; both timelines have one "You met" entry; editing it from one page says it also changes the other, and changes both.
- [ ] "Open chat" on a couple thought asks whom first; after a write thought "Did you write to Tom?" Yes records for Tom only, after a meet thought "Did you meet Anna & Tom?" records for both.
- [ ] "Did it happen?" for a dated couple thought, and Done on it, record for both.
- [ ] Unlink: the confirm says what happens to shared thoughts; afterwards they are two people again, the thoughts belong to the first one and the shared meetings stay on both timelines. Deleting one of the two says the link goes too.

## Any messenger (not released yet)

- [ ] After the update to schema 6, every person still has their messenger; nothing else changed.
- [ ] A person imported from contacts, messenger Signal, no chat link: "Open Signal" opens the chat with them through the contact (also for WhatsApp and Telegram).
- [ ] The same person with a chat link entered: the link wins.
- [ ] A contact with a chat link in its Website field (for example `https://t.me/<name>`), messenger set to that app, no chat link in Kept.: "Open" uses the contact's link.
- [ ] Messenger SMS: "Open" starts a message to the number in the default SMS app.
- [ ] The messenger choice on the edit page, on first start and in the contact import shows only the apps installed on the phone (and the person's current one).
- [ ] A person whose messenger was uninstalled: "Open" says it is not installed.
- [ ] Edit a person imported from contacts who has Signal, Telegram or WhatsApp in the contact: those apps (and SMS when they have a number) show under "From the contact", the others under "Other apps on this phone", each with its icon.
- [ ] The line under the chat link field changes as you type: a Signal username says a full link is needed; a pasted link says Open goes straight to the chat; empty says what Kept. does instead. Check the German texts too.
- [ ] LinkedIn with a bare profile name (from the address bar of their profile): "Open LinkedIn" starts a new message to them, in the LinkedIn app or, if the app does not take the link, in the browser.
- [ ] Discord: paste a "Copy Message Link" link as it is (with the message number): "Open" goes to the DM.
- [ ] "How do I get a chat link?" under the field opens the help page with the chosen app first; read the German texts (other apps' menu names such as „Nachrichtenlink kopieren“ are guesses).
