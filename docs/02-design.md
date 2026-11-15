# 02 Design

Status: **closed by the developer on 2026-11-15.** It began as a draft proposal by Claude on 2026-11-14; §6 keeps the history of how each point was settled, including names used along the way (the working name "Friends" on the concept screens). Changes from now on are listed in §8, not written into the text. Background and reasons are in [01-research.md](01-research.md); F#, Q# and B# refer to it.

## 1. What the app is

A personal Android app. It catches the thought "I should contact X" when it occurs, brings it back when the user has time, and makes acting on it a small step. It also tells the user when a reply is owed and follows up on birthdays.

Design rules, from research:

1. **One thing at a time.** The user never faces a list of neglected people.
2. **"Not today" is free.** Nothing becomes overdue, nothing expires, no counters of days.
3. **Capture in under ten seconds**, from outside the app.
4. **The step after the nudge is small.** One tap to the right chat, with the user's own reason on screen.
5. **Neutral words.** "Anna came to mind." No red, no blame.
6. **Works on first use** with almost no setup. Sessions take a few minutes at most.

## 2. Main flows

### 2.1 Capture (F1)

**Decided (the developer, 2026-11-14): no always-visible notification.** Q7 in research came from a misunderstanding. The user opens the app when a thought comes. See §7.

The app opens on a **landing screen**. Its top part is quick capture:

1. A text field, ready to type ("saw a bouldering video").
2. Pick the person (recent people first, then search).
3. Optional: kind (write, call, meet). Default: write.
4. Save. The field clears.

Below the capture part the landing screen shows what is open (2.3).

Long-press on the app icon jumps straight to capture. Sharing a link or photo into the app opens capture with the content attached (later milestone).

Risk (Claude): capture now depends on the user thinking of the app. Keep the icon where it is seen, and watch in the own-use numbers (M8) whether captures happen.

### 2.2 Evening question (F2)

Once a day at a time the user sets, not on excluded days: "Got ten minutes for someone today?" with **Yes** and **Not today**.

- **Not today:** the notification goes away. Nothing else happens.
- **Yes:** the app opens on the open items (2.3).
- No answer: counts as "Not today".

### 2.3 Open items on the landing screen

**Decided (the developer, 2026-11-14):** a setting switches between **one item** and a **short list of three**. Start value: one item (proposed).

An item shows the person, the reason the user noted, and the last note about them. Buttons:

- **Open chat** opens the person's main messenger (F4).
- **Another one** shows the next item (one-item mode only).
- **Done** closes the item. The app offers one optional line for next time ("new job in March").

When the user comes back after "Open chat", the app asks "Did you write?" with Yes / Not yet.

"Yes" on the evening question opens the landing screen scrolled to the open items.

### 2.4 What gets picked

In this order:

1. A birthday today.
2. A reply owed for longest.
3. The reconnect person of the week (F13).
4. The user's own captured intentions.
5. A person whose class rhythm suggests it has been a while (F8).

### 2.5 Birthdays (F5)

On the evening of a birthday: "Congratulated Anna yet?" with **Yes**, **Open chat**, **Later**. Birthdays come from the phone contacts.

### 2.6 Owed replies (F6, Q9)

An optional part that reads incoming message notifications. If a person on the list writes, the app notes it. It cannot see the user's answer. So:

- The item only appears as "owed" after a waiting time (start: two days).
- It is shown as a question: "Still owe Jonas a reply?" with **Open chat** and **Already answered**.
- Opening the chat from the app clears it.

Fallback without this part: some days after the user opened a chat from the app, it asks "Did Jonas answer? Do you owe a reply?".

## 3. Data (sketch, updated 2026-11-15)

| Thing | Holds |
|---|---|
| Person | Name, link to phone contact, class (Close friends, Now and then, A few times a year) or Family, own rhythm if it differs from the class, main messenger and how to reach them there, birthday, "getting back in touch" state, notes |
| Idea | Belongs to a person. Something to do or talk about (F11) |
| Intention | Belongs to a person. Reason text, kind (write, call, meet, reply owed, birthday), optional attached link, open / done / dropped. **When:** a date and time, or a horizon (soon, later, when + condition text), or nothing |
| Contact event | Person, date, kind (wrote, called, met, birthday wish), **direction** (by the user, by the other person, together), source (confirmed in the app, entered by hand, seen by the listener), optional one-line note |
| Treat | Name, stamps needed, state (waiting, current, earned, enjoyed) |
| Stamp | Date, the contact event it came from, value. Kept so the count can be explained and the rule changed later |
| Day answer | Date and Yes / Not today / no answer. For the user's own statistics |
| Settings | Evening time, excluded days and hours, one or three items, theme, language, class rhythms, stamp weights and default card size, the user's own birthday, switches for optional parts |

Later, with groups (F12): a contact event can belong to several people, so a shared meet-up shows everyone's bubble.

The friend timeline is not stored. It is built from the person's contact events (history) and their birthday and dated intentions (upcoming). The Upcoming tab is built the same way across all people.

All data stays on the phone. No account, no server.

## 4. Technology

**Approved by the developer on 2026-11-15**, after a walk through the alternatives. Anything not listed here is asked first.

| Job | Package | Permission | Alternatives looked at |
|---|---|---|---|
| Framework | Flutter | | |
| Database | `drift`, `drift_flutter` | none | `sqflite`, `hive_ce`, `objectbox` |
| Screens to data | `flutter_riverpod` | none | `provider`, `flutter_bloc` |
| Notifications | `flutter_local_notifications`, `timezone`, `flutter_timezone` | notifications | `awesome_notifications` (its extras are not needed) |
| Contacts and birthdays | `flutter_contacts` | contacts (read) | system picker without permission |
| Opening chats | `url_launcher` or `android_intent_plus` | none | **Decided in M0** by a test on the phone: whichever opens WhatsApp, Telegram, Signal and Discord reliably |
| Icon long-press | `quick_actions` | none | |
| Colourful icons | `flutter_svg` | none | `vector_graphics` |
| Look | `material_3_expressive`, `material_ui` | none | built-in Material 3 only |
| Languages | `intl`, `flutter_localizations` | none | |
| Helpers | `permission_handler`, `path_provider`, `uuid` | none | |
| Notification access (Q9, D11, call notifications) | own Kotlin code, no package | "Notification access", switched on by hand | listener packages |

Start without the exact-alarm permission; test in M0 whether the evening question arrives close enough to its time.

Not verified: that `flutter_contacts`, `quick_actions` and `flutter_svg` are current and maintained. Check versions at project setup. The alternatives were named from Claude's knowledge, not checked against pub.dev.

State management, folder layout and tests follow akai-timetrack unless there is a reason not to. To be written in 04-architecture.md.

## 5. Milestones

**Approved by the developer on 2026-11-15.**

| # | Milestone | Done when |
|---|---|---|
| M0 | Project setup and risk checks | App runs on the developer's phone with the theme (dark and light) and the icon set. Checked on the phone: a scheduled notification arrives close to its time, also after a restart, without the exact-alarm permission; notification buttons work without opening the app; chats open in WhatsApp, Telegram, Signal and Discord (this picks `url_launcher` or `android_intent_plus`); the listener sees an incoming WhatsApp message and a WhatsApp call notification; the installed messenger's icon can be read. |
| M1 | People | Import chosen contacts on first start, set class or Family and main messenger. People screen and the top of the person page. |
| M2 | Capture | Capture on Home and from the icon in under ten seconds, with kind (write, call, meet). Intentions are stored. |
| M3 | Evening question and open items | The daily question arrives, Yes leads to the open items, Open chat works, "Did you write?" and the "Nice one" screen with the note for next time. One item or three, by setting. Contact events are stored with direction "by the user". **First version the developer uses daily.** |
| M4 | Birthdays | Evening follow-up on birthdays; "You congratulated" is recorded. The user's own birthday in settings, and entering who congratulated. |
| M5 | Upcoming and plans | Dates on intentions, the Upcoming tab, the coming-up cards on Home, "Did it happen?" after a date, undated plans with soon / later / when…, and their return as evening picks. |
| M6 | Friend timeline | The compact timeline on the person page, "They wrote" and "They called" buttons. |
| M7 | Owed replies and incoming contact | Listener part with waiting time and question; incoming messages and messenger calls recorded automatically. Can be switched off. |
| M8 | Rhythm and reconnect | Editable class rhythms, gentle hints, reconnect person of the week. |
| M9 | Stamps and treats | Stamp rule with editable weights, stamp cards, default treats, Progress screen, own-use numbers. |
| M10 | Ideas and sharing in | Ideas per person as notes; share a link or photo into the app. |

Order after M3 follows the developer's wish for birthdays first (D4). M5 and M6 were added on 2026-11-15; their place in the order is Claude's proposal.

Later: groups and shared events (F12), small things to do soon such as voice messages (§6.12), doctor appointments (B1), finding lost people (B2), suggested texts (B5), iOS (B3).

## 6. Open design questions

| # | Question | State |
|---|---|---|
| D1 | How capture works | **Decided** (the developer, 2026-11-14): on the app's landing screen, no always-visible notification. See 2.1. |
| D2 | After "Yes": one item or a short list of three? | **Decided** (the developer, 2026-11-14): a setting switches between the two. |
| D3 | Language of the app's texts | **Decided** (the developer, 2026-11-14): German and English from the start. |
| D4 | What comes first after M3 | **Decided** (the developer, 2026-11-14): birthdays. |
| D5 | Names and number of friend classes, default rhythms | **Decided** (the developer, 2026-11-15): three plus Family, rhythms editable in settings. Default numbers proposed, see §6.9. |
| D6 | Forms of gamification and how treats work | Partly decided 2026-11-15: stamp card, stamps per treat, default treat list, meet-ups double. Stamp rule confirmed as a start with editable numbers, see §6.9 and §6.10. |
| D7 | Look of the app (concept screens) | First concept reviewed 2026-11-15: the developer finds it boring, clinical in colour and too business-like, and wants more playfulness. V2 made the same day: liked in idea but overshot, emoji icons rejected, stamp card and timeline liked. V3 tryout (Material 3 Expressive remix, dark and light) made the same day: more mature and a step forward, but it lost the character, and its icons are boring. V4 tryout made the same day: liked (icons, shadows, tilted date badges, stamps). V5 made the same day with the developer's corrections; accepted as the direction, except the off-centre stamps. V6 (full set of screens in that look) made the same day and liked ("this looks great"). Light mode drawn for four screens. Dark mode is wanted (the developer, 2026-11-15). See §6.1 to §6.6. |
| D11 | Record both directions: who reached out, and birthday wishes given and received | Asked for by the developer 2026-11-15. How birthdays show is **decided** (§6.8). How incoming contact is recorded is open, see §6.7. |
| D10 | Per-friend timeline (history and upcoming on the person page) | **Decided** (the developer, 2026-11-15): compact timeline as in V6. See §6.6, §6.8. |
| D9 | Timeline of upcoming events | Asked for by the developer 2026-11-15. Shown in V2 as its own tab. Details open, see §6.2. |
| D8 | App name | **Decided** (the developer, 2026-11-15): **Kept**. The name shown to the user can change later without touching stored data, as long as the app ID stays the same. App ID: `de.gartenpa.kept` (decided the same day; never changes). |

### 6.1 Concept screens

Nine screens on one canvas: https://claude.ai/artifact/WW7Y4AiXwbDkKEJYGePfhR (private to the developer). Sources are in `docs/concepts/` (`canvas.json` plus one `.dc.html` per screen). To change a screen, edit the source and publish it to that address again.

| # | Screen | Shows |
|---|---|---|
| 1 | Home | Capture field with recent people, and one open item |
| 2 | Capturing | Text typed, person and kind picked; open items as a list of three |
| 3 | Notifications | Evening question, birthday follow-up, owed reply, reconnect person of the week |
| 4 | Back from the chat | "Did you write?", note for next time, keep open until a date is set, count and treat |
| 5 | People | Reconnect card, people grouped by class, family |
| 6 | One person | Class, messenger, birthday, ideas, notes, recent contact |
| 7 | First start | Pick a few contacts and set how close |
| 8 | Progress and treats | Growing count, next treat, week view, weeks in a row, own-use numbers |
| 9 | Settings | Evening time and days, one or three items, optional parts, language |

The concept makes choices that are not decided: four bottom tabs, the class names "Close friends / Now and then / A few times a year / Family" (D5), a treat after three people and a week row that pauses (D6), green and amber colours, the Nunito typeface. Texts are English only. Not checked on a phone.

### 6.2 Concept V2 (2026-11-15)

Third row on the same canvas. Six screens; notifications, first start and settings are not redone until the direction is confirmed. Sources: `docs/concepts/V2*.dc.html`, generated by `docs/concepts/gen_v2.py` (shared look in one place; run it with the output folder and `docs/concepts` as arguments).

| # | Screen | Shows |
|---|---|---|
| 1 | Home | Capture card, "Tonight's pick" with the noted reason, a peek at the next two dates |
| 2 | Upcoming (new) | Timeline by week: birthdays and meet-ups or calls with a date; one "no date yet" entry |
| 3 | After "Yes, I wrote" | Small celebration, note for next time, "planning to meet up?", full treat stamp card |
| 4 | People | Reconnect card, people as avatar bubbles by class |
| 5 | One person | Header with avatar and tags, next date, ideas as sticky notes, notes, recent contact |
| 6 | Progress and treats | Count with avatars of people reached, stamp card, week with stars, weeks in a row |

Proposals in V2, none decided:

- **Look:** cream ground, plum ink, coral, yellow, mint, lilac, sky and pink as fills; thick outlines with a hard shadow ("sticker" look); Fredoka for headings, Nunito for text.
- **Emoji per person** as the avatar, picked by the user.
- **Tabs:** Home, Upcoming, People, Progress. Settings moves behind a gear on Home.
- **Treats as a stamp card:** one stamp per person reached, three stamps fill a card.
- **Timeline content:** birthdays from contacts and intentions that have a date. Nothing in it can be overdue (rule 2). Meet-ups without a date sit in a separate "no date yet" box.

Consequence for the data sketch (§3) if D9 is confirmed: an Intention gets an optional planned date and time.

Not rendered or checked on a phone.

### 6.3 Concept V3 tryout (2026-11-15)

Developer feedback on V2: creative and more playful, but slightly overshot. Liked: the stamp card and the timeline. Disliked: emoji as icons. Wanted: a flat or Material icon style, a dark mode (the developer always uses dark), and a small tryout that mixes V2 with Material 3 Expressive. V2 stays on the canvas for later.

Fourth row on the canvas: Home, Upcoming and Progress, each in dark and light. Sources: `docs/concepts/V3*.dc.html`, generated by `docs/concepts/gen_v3.py`.

What V3 does, all proposals:

- **Material 3 Expressive base:** tonal surfaces, large rounded containers, pill buttons, a navigation bar with a pill around the active icon. No outlines or hard shadows.
- **Kept from V2:** stamp card with slightly rotated stamps, the timeline, the rotated "Tonight's pick" tag, the six accent colours.
- **Dark theme first:** plum-tinted dark ground; cards use deep tonal versions of the accents; bright accents only on buttons, avatars, stamps and date badges.
- **No emoji:** icons are Material Symbols Rounded, filled. People are shown by their initial in a coloured shape (scalloped, squircle, leaf, arch).
- **Type:** Outfit for headings, Roboto for text.

The ENIX icon pack the developer named was looked up, but its style could not be confirmed (the store page and screenshots were not readable; only the tagline "shapeless, vibrant" from a third-party mirror). It did not influence V3. The developer said to use it only if it fits.

In a Flutter app, Material 3 Expressive components are not all available in the stable Material library (unverified, to check in M0). The look can be built with standard Material 3 widgets plus custom shapes.

Not rendered or checked on a phone.

### 6.4 Concept V4 tryout (2026-11-15)

Developer feedback on V3: a more mature version and a step forward. What gave V2 its character is missing: the slightly tilted notes and the shadows on UI elements. The confetti on the "Yes, I wrote" screen was loved. The icons are too boring; colourful icons might fit better. The small plain icons on coloured areas (the "Open chat" button, the coming-up cards) might be fine as they are; the developer is split and wants both shown. The developer supplied screenshots of the ENIX icon pack: flat, shapeless, vivid icons built from two or three tones of a colour, rounded, with a slight shadow.

Fifth row on the canvas, dark only: Home A, Home B, Upcoming, After "Yes, I wrote", One person, Progress. Sources: `docs/concepts/V4*.dc.html`. Their generator was developed further into `gen_v5.py`, so the V4 files are the record of V4. Rendered pictures: `docs/concepts/previews/`.

What V4 does, all proposals:

- **V3 as the base:** dark tonal surfaces, pill buttons, initials in shapes, Outfit and Roboto.
- **Character back from V2:** a hard shadow under cards, buttons, date badges and stamps; tilted tags, date badges, sticky notes, stamp card and coming-up cards; confetti on the "Yes, I wrote" screen. No outlines.
- **Colourful icons:** a small set drawn for this concept in the ENIX manner (house, calendar, people, stamp, cake, mountain, phone, dice, chat, check, gear, search, popcorn, star, leaf). They are placeholders drawn by Claude, not a licensed icon pack. No app or brand logos.
- **Two icon paths on Home:** A uses the colourful icons everywhere. B keeps plain Material Symbols on coloured areas (the coral button, the coming-up cards) and uses colourful icons only on neutral areas (navigation, timeline, grey buttons).

Open for the app itself: where a full colourful icon set comes from (draw our own as SVG, or find a pack whose licence allows use inside an app). ENIX is a launcher icon pack of app icons, so it cannot supply UI icons.

Checked: rendered with headless Edge from a plain HTML copy of the screens and looked at by Claude; nothing clipped or overlapping. Not checked on a phone, and not checked inside the canvas itself.

### 6.5 Concept V5 (2026-11-15)

Developer feedback on V4: loves the icons, the shadows, the tilted date badges and the stamps. Decided for now (the developer, 2026-11-15): **colourful icons everywhere**; going back to plain icons on coloured areas stays possible. Tilt was overdone: large cards should be straight, small things, above all the notes, may be tilted. Ideas from the developer: show the app icon of the friend's main messenger on "Open chat"; let stamps sit slightly off, as on a real stamp card. V4 stays on the canvas.

Sixth row on the canvas, dark: Home, Upcoming, After "Yes, I wrote", One person, Progress. Sources: `docs/concepts/V5*.dc.html`, generated by `docs/concepts/gen_v5.py`. Rendered pictures: `docs/concepts/previews/v5-*.png`.

Changes against V4:

- **Icons:** colourful everywhere. The plain-icon Home variant is dropped.
- **"Open chat" and "Open WhatsApp"** carry a small messenger app icon. On the concept it is a drawn stand-in for WhatsApp.
- **Tilt rule:** cards are straight. Tilted are only tags, date badges, sticky notes and stamps. The coming-up cards on Home are straight and carry a tilted date badge, as on the timeline.
- **Stamp card:** every slot is a printed dashed ring; each stamp lands a few pixels off its ring and at its own angle.

Open points from V5:

- **Messenger icon in the app.** Two ways. (a) Read the installed app's real icon from the phone. This needs no permission, but the app must declare the messenger packages in the manifest (`<queries>`), and it needs a plugin or a few lines of native code. Unverified; check in M0. (b) Ship our own drawn icons. Using other companies' logos in a published app touches their brand rules. To discuss before publishing (Q2).
- **Colourful icon set.** A ready pack with a licence that allows use inside an app would be easiest; none has been looked for yet. Otherwise draw our own, as on the concept.

Checked: rendered with headless Edge and looked at by Claude; nothing clipped or overlapping. Not checked inside the canvas or on a phone.

### 6.6 Concept V6, full set (2026-11-15)

Developer feedback on V5: draw the rest of the screens. The off-centre stamps are a no; "maybe just slightly rotated", not sure. New wish: each friend has a timeline of their own, history plus upcoming things, reached by scrolling down on their page, in a more compact style.

Seventh and eighth row on the canvas, dark. V5 stays as it is. Sources: `docs/concepts/V6*.dc.html`, generated by `docs/concepts/gen_v6.py`. Rendered pictures: `docs/concepts/previews/v6-*.png`.

| Row | Screen | Shows |
|---|---|---|
| Every day | Home | As V5. The gear leads to Settings |
| | Capturing, and the list of three | Text typed, Tom picked, kind chips (Write, Call, Meet), "Save for Tom"; open items as three compact rows, each with the messenger's icon as the button |
| | Notifications | The four notifications: evening question, birthday, owed reply, reconnect person of the week |
| | Back from the chat | "Did you write to Tom?" with "Yes, I did" and "Not yet" |
| | After "Yes, I wrote" | As V5, stamps only tilted |
| | Upcoming | As V5 |
| People and settings | People | Reconnect card for Jonas, people as initials in shapes by class |
| | One person | As V5 |
| | One person, scrolled down (new) | Compact timeline: upcoming on top (tilted date pills), a "Today" mark, history below with date, icon, one line and an optional note |
| | First start | Pick contacts, set how close with a pill per person |
| | Progress and stamp card | As V5, stamps only tilted; empty slot is a dashed ring |
| | Settings | Evening time and days, optional parts as switches, one or three items, theme, language, classes |

Proposals in V6, none decided:

- **Stamps** are tilted a few degrees and sit in place, as in V4.
- **Per-friend timeline (D10).** History entries come from Contact events (§3), upcoming ones from the person's birthday and dated intentions. The first entry is "Added to your people".
- **Settings is not a tab.** It opens from the gear on Home and has a back arrow.
- **Theme setting** with System, Dark and Light. Only dark is drawn.
- **A second messenger stand-in** (Telegram, for Jonas) shows that the button's icon follows the person's main messenger.
- **Notification text** "Tom, Anna and one more are on your mind" under the evening question is new and names people. Rule 1 (never a list of neglected people) may speak against it. To discuss.
- The placeholder app name on the notifications is "Friends" (D8 is open).

Checked: rendered with headless Edge and looked at by Claude. Two glitches were found and fixed (spacing on People, a wrapping date pill on the friend timeline). Not checked inside the canvas or on a phone.

### 6.7 Review of V6 (2026-11-15)

The developer's answers on V6:

| Point | Answer (the developer, 2026-11-15) |
|---|---|
| Overall look | "This looks great." V6 is the look to continue with. |
| Settings behind the gear, not a tab | Good. Decided. |
| Messenger app icon on the chat buttons | Good. Decided. How the icon is obtained is still open (§6.5). |
| Coral as the main button colour | Kept for now. The developer likes it but notes that red reads as "destructive". Open to a better idea. |
| Evening notification that names people | Kept for now. |
| App name | Still open (D8). "Friends" is "definitely not wrong" and stays as the working name. |

Claude's view on the button colour: the coral is a warm orange-pink, not the red used for errors and deleting, and nothing in the app is destructive except deleting a person. If it still bothers the developer in use, the nearest alternative from the palette is the yellow (already the colour of capture and of the active tab), with coral kept for small accents. No change made.

New wishes from the developer:

- **Both directions of contact (D11).** So far the design mostly records when the user reaches out. It should also record when the other person reaches out. The Contact event (§3) gets a direction: by the user, by the other person, or together (a meet-up).
- **Birthdays in both directions (D11).** Record for each birthday whether the user congratulated, "even though it's maybe slightly blaming". Also allow entering who congratulated the user on the user's own birthday. This needs the user's birthday in the settings.
- **Shared events (later, with groups F12).** An event with several friends should show all of them, for example as their small bubbles on the timeline entry.

Claude's notes on D11, to discuss: recording "not congratulated" must not turn into a list of misses (rules 2 and 5). Proposal: the timeline shows "You congratulated" when it happened and nothing otherwise; the plain fact stays in the data. Who reached out can partly come from the owed-reply listener (Q9), which already sees incoming messages from listed people; otherwise it is entered by hand.

Light mode: a ninth row on the canvas shows Home, Upcoming, the friend timeline and Progress in light (`V6Light*.dc.html`, pictures in `docs/concepts/previews/v6-light-*.png`). The friend timeline in that row already shows the D11 idea: small arrows for "You wrote" and "Tom wrote", and "Your birthday: Tom congratulated you". Rendered and looked at by Claude; not checked on a phone.

### 6.8 Decisions after the V6 review (the developer, 2026-11-15)

- **Their birthday in the friend timeline:** the entry always appears. It says "You congratulated" when the user did. Otherwise it shows only the birthday, with no remark.
- **The user's own birthday:** an entry appears only for people who congratulated. Misses are not shown.
- **Friend timeline (D10):** the compact style in V6 is good. Decided.
- **Stamps:** slightly tilted and in place, as in V6. Decided. This settles the look of the stamp card; how treats work (D6) is still open.

### 6.9 Open questions settled on 2026-11-15 (the developer)

**Friend classes (D5), decided.** Three classes plus Family: Close friends, Now and then, A few times a year; Family is a separate group. "Getting back in touch" is a state on top of a class, not a class. Default rhythms (proposed by Claude, not yet confirmed as numbers): about 2 weeks, 6 weeks, 3 months. The rhythms can be edited in the settings. A rhythm only drives the gentle hint, never an overdue mark.

**Treats (D6), partly decided.**

- Each treat has its own number of stamps.
- The app ships a list of default treats so the user does not have to invent them. Proposed list, to be confirmed: favourite takeaway (10), cinema evening (10), cake from the good bakery (10), a new book or game (20), a lazy morning with nothing planned (10), a day trip (30), concert or event ticket (40).
- A stamp is given at most once per person in a period, and a meet-up counts double.
- Daily chats with close friends must not fill cards. The developer writes daily with about three close friends. The developer chose "weekly, weighted" and also likes "only after a gap", and asked for a mix.
- **Proposal for the mix (Claude, not confirmed):** at most one stamp-earning contact per person per week. Its value: Close friends 1, Now and then 2, A few times a year 3. Plus 1 if the person is in "getting back in touch". Plus 1 if the last contact was longer ago than the person's rhythm. A meet-up doubles the total. Default card size 10.

**Incoming contact (D11), decided.** Automatic where the notification listener is on (at most one entry per person per day), plus a "They wrote" / "They called" button on the person page.

**Call detection, decided.** No call-log permission: Google Play restricts it to dialer-type apps (unverified in detail, Claude's knowledge of the policy). Ordinary phone calls are entered by hand. In M0, test whether call notifications of WhatsApp, Signal and Telegram can be recognised through the existing notification access. Unverified.

**Upcoming tab (D9), decided.** Birthdays for the next 12 months and anything with a date. When a date has passed, the app asks once "Did it happen?"; the entry then moves to history or back to the undated plans. Nothing becomes overdue.

**Undated plans, new idea by the developer.** A concrete plan without a date gets a rough horizon instead: **soon** (usually within a few weeks), **later** (within a couple of months), or **when…** (tied to a condition the user writes, for example "when it is warm again"). These replace the single "No date yet" box. Open: whether and how the app brings them up again.

**Technology (§4): approved** later the same day, see §4.

Consequences for the data sketch (§3), to be written in once the above is confirmed: Intention gets an optional date and time or a horizon (soon, later, when + condition text); Contact event gets a direction; Person gets a rhythm override; Treat is a new thing (name, stamps needed, state); settings get the user's own birthday and the class rhythms.

### 6.10 Confirmed on 2026-11-15 (the developer)

- **Stamp rule:** the mix proposed in §6.9 is taken as the start. The weights and card sizes are editable in the settings, so the developer can rebalance after some weeks of use.
- **Default treats:** the list in §6.9 is a good start. Add treats that are also constructive. Added by Claude: cook something really fancy (10), bake something new (10), a new plant or something for the flat (20), start a small project you have been putting off, with the materials bought (20), a class or workshop (30).
- **Rhythm defaults:** 2 weeks, 6 weeks, 3 months.
- **Undated plans come back as evening picks:** a "soon" plan after about two weeks, a "later" plan after about two months, each as "Want to set a date with Tom?". "When…" plans never come up by themselves. In the pick order (§2.4) they sit with the user's own captured intentions.

Still open: the app name (D8); how the messenger icon is obtained and where the colourful icons come from (§6.5); the developer's OK on the milestones (§5, updated the same day); the data sketch (§3) was updated the same day.

### 6.11 V6b tweaks (2026-11-15)

Developer remarks on V6: the settings button seems to have no shadow in dark; the people blobs in "Who's on your mind?" have no shadows; the magnifier icon looks out of place next to the people blobs.

A tenth row on the canvas shows Home, Capturing and People with three changes (`V6b*.dc.html`, picture in `docs/concepts/previews/v6b-home-capture.png`):

- Grey buttons get a darker shadow. The old one was almost the colour of the dark ground, so it only showed on cards.
- People blobs get the same small hard shadow as the large avatars.
- "More" is a grey round blob with three dots instead of the magnifier.

Rendered and looked at by Claude. **Accepted by the developer on 2026-11-15** ("tweaks look good").

### 6.12 Future idea: small things to do soon (the developer, 2026-11-15)

Listening to long voice messages is "very troubling" for the developer. Idea: a kind of quick to-do for a person that should be done as soon as possible, for example "listen to Tom's voice message". Such items do not appear in the timelines. Marked by the developer as maybe a future feature; not in the milestones.

Claude's notes, not discussed: it could be one more kind of Intention ("listen", "do soon") that shows in the open items and evening picks only. The listener (Q9) may be able to tell that an incoming message is a voice message from its notification text; unverified. It is close to owed replies (F6), since an unheard voice message usually is an owed reply.

### 6.13 Icon sets compared (2026-11-15)

The developer asked for a search for a colourful icon pack, a comparison with our own icons, and to see well-fitting sets even without a usable licence, since the app is private at first.

A Sonnet subagent searched; Claude fetched sample icons through the Iconify API and put them on one board next to ours, on dark and on light (`IconCompare.dc.html` on the canvas, picture in `docs/concepts/previews/icon-compare.png`). The samples were picked by a keyword search, so some are poor matches for the concept (for example a "play" button under "star").

| Set | Licence (as read by the subagent) | Look on the board | Covers our concepts |
|---|---|---|---|
| Ours | none needed | The reference | 13 of 14 drawn; every further icon has to be drawn |
| Fluent Emoji Flat (Microsoft) | MIT | Flat, multi-colour, no outlines. Softer and more detailed than ours; they are emoji drawings | All 14, about 3,100 in total |
| Streamline Plump Color, Flex Color | CC BY 4.0, credit required | One blue tone with dark outlines. Not our style | Most |
| Streamline Kameleon Color | CC BY 4.0, credit required | Small scenes inside coloured circles. Not our style | About half |
| Streamline Stickies Color | CC BY 4.0, credit required | Outlined stickers | Few |
| Icons8 Flat Color Icons | MIT or "Good Boy License", repo archived | Older flat style, thin | About half |
| Fluent UI System Color (Microsoft) | MIT | Not on the board | Poor: no cake, dice, popcorn, mountain |

Not on the board because they cannot be fetched freely: Icons8 "Fluency", "Color" and "Plasticine", and Flaticon flat colour packs. The subagent judged them the closest in style but could not read their licences; from its memory, free use needs a visible link to the source and paid plans remove that. Unverified. They can be looked at on icons8.com and flaticon.com.

Licence statements are from page labels and summaries, not from the full licence texts. Check the texts before shipping any set.

Claude's assessment: only Fluent Emoji Flat is a real alternative. It would save drawing and covers everything, but it is an emoji set, and the developer rejected emoji as icons in V2. Our own icons fit the look best. Decision is the developer's.

### 6.14 Icons and style guides (2026-11-15)

- **Decided (the developer):** the app uses its own drawn icons. "Our icons are by far the best." More have to be drawn as the app grows.
- The icon style is written up in [style/icon-style.md](style/icon-style.md), with a view to a later skill for drawing new icons.
- The UI style is written up in [style/ui-style.md](style/ui-style.md), in a form that can be adapted for other apps.
- The V6b tweaks (§6.11) are part of the style guide and accepted.

## 7. Changes to earlier decisions

| Date | Change |
|---|---|
| 2026-11-14 | **Q7 withdrawn.** Research recorded "a notification that stays at the top" as the main capture path. The developer says this was a misunderstanding and does not want an always-on notification. Capture happens in the app (D1). |

## 8. Changes made during implementation

| Date | Change |
|---|---|
| 2026-11-15 | **Name (the developer):** the app is called "Kept." with the full stop. The app label carries it. Running text may write Kept. The app ID and file names stay without it. |
| 2026-11-15 | **Version (the developer):** starts at 0.1.0+1 instead of Flutter's 1.0.0+1. Claude chooses the steps on the way; 1.0.0 is the first real release. Plan (Claude): the minor number follows the milestones, so M3, the first version in daily use, is 0.3.0. |
| 2026-11-15 | **Demo data (the developer):** development builds can fill the app with invented people and history, to work with and for screenshots. Not in release builds. Built in M1 with the people table. |
