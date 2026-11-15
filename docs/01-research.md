# 01 Research

Status: **closed** by the developer on 2026-11-14. Started 2026-11-13. Later changes of mind go into 02-design.md, not here.

## 1. Problem

The user has ADHD. Friends who are not in view drop out of mind. Starting contact is hard, and after a long silence guilt makes it harder. Two goals:

- **Keep**: stay in regular contact with current friends.
- **Reconnect**: get back in touch with childhood friends after years of silence.

## 2. Market scan (2026-11-13)

Done by a Sonnet subagent using web search. **Limits:** most prices and status come from vendor or competitor blogs (largely Kinu's, which sells a rival app). No store reviews or Reddit threads were read directly. Check store pages before relying on any detail.

**The space is crowded.** Dex lists 60+ "personal CRM" apps (https://getdex.com/blog/personal-crm-list/). Most are aimed at professional networking. Friendship-first, shame-free and cheap is a much smaller set.

### 2.1 Closest existing apps

| App | Platform | Status | Price | What it does | Weak spots |
|---|---|---|---|---|---|
| Kinu | iOS, Android, web | Active | Free to 10 people; $6.99/mo, $69.99/yr or $149.99 once | Local-first reminders and notes, no streaks, says it is guilt-free | Free tier of 10; sync is paid; claims are from the vendor |
| Catchup | iOS, Mac | Active (May 2026) | Free | Plain reminders, collects no data | No notes; Apple only |
| Fabriq | iOS, Android | Active (mid 2026) | Free to 150; $4.99/mo | Circles of closeness | Play rating 2.4; freezes, missed notifications |
| Dex | iOS, Android, web | Active | $12–20/mo, no free plan | Imports, email/calendar logging, AI openers, log by WhatsApp text | Feels like a sales tool; price |
| Clay (now Mesh) | iOS, desktop, web | Active (Automattic, 2025) | Free to 1,000; $10/mo | Contact sync, automation, AI | No Android; professional framing |
| Monica | Web, self-hosted | Active, slow | Free self-hosted | Notes, reminders | No mobile app |
| Soonly | Web, SMS | Active | $2/mo | Daily conversation starter by SMS | No notes or context |
| Amiqo, Linger, Rekindle, YouLet, dearever | Mostly iOS | New in 2025–26, few ratings | Unverified | AI-drafted first messages, daily pick from contacts | Unvetted |

Dead or dormant: UpHabit (closed April 2026), Garden (2020), Touch'd, Keep My Friends. Not verified: Covve, Smart Contact Reminder (Android, said to be built for neurodivergent users), Kinly, Call Your Friends, Orbit, Hippo, Ntwrk.

### 2.2 Why people give up on these apps

Thin evidence, from blogs and one r/ADHD mirror.

- Full CRMs are too much work for private use.
- **Reminders alone do not stick.** The reminder fires, the user still does not write, the list becomes a pile of guilt.
- Dex and Clay read as sales tools.
- Subscriptions, capped free tiers, unreliable notifications.
- Small apps die and take the data with them.

### 2.3 Platform limits

- iOS: no access to call history or other apps' messages. Contact access can be limited to chosen contacts (iOS 18).
- WhatsApp, Signal: no public API to read a user's chats (not checked directly).
- Android: a call-log permission exists but Google Play restricts it (details unverified). A notification listener could see incoming message notifications (idea, unverified).
- In practice every app relies on manual logging, calendar/email scraping, or text-to-log. None detects last contact from messengers.

### 2.4 Gaps

1. **From reminder to sent message.** Nobody closes the step where ADHD users actually fail: starting. Draft tools exist but are new and iOS-only.
2. **Reconnect after years.** Only brand-new, barely rated apps. Nothing helps find an old friend's current contact details.
3. **Shame-free on Android.** Kinu is the only real candidate.
4. **Automatic "last contact".** Nobody has it. Android may allow a partial version.
5. **German/European focus.** Nothing found.

## 3. Assessment (Claude, 2026-11-13)

Apps like this exist. Kinu is close to the "keep" half of the idea. So this is not an empty market, and a commercial product would face many competitors.

Reasons it can still be worth building:

- As a personal tool, tuned to the developer's own failure points, with no need to win a market.
- The category's known failure is that reminders do not lead to action. An app built around the *start* (one tap from nudge to a pre-written message in WhatsApp) and around the *reconnect* case would differ from what exists.

The risk is building another reminder list that gets ignored after two weeks, as the existing ones do.

## 4. Decisions

| # | Topic | Decision |
|---|---|---|
| Q1 | Build, or use an existing app? | **Build** (the developer, 2026-11-13). Kinu's free tier of 10 people is too small, paying is not wanted, and building it is part of the fun. |
| Q2 | Personal tool or product for others? | **Personal tool for now** (the developer, 2026-11-13). If it works well, publishing for others will be explored. So: anything that could risk Google Play compatibility or needs many permissions is discussed first. Trying such things on the developer's own phone is fine. |
| Q3 | Platforms (Android, iOS, both) | **Android first** (the developer, 2026-11-13). The developer uses Android. iOS open. |
| Q4 | Only people, or any lost intention (e.g. doctor appointments)? | **People only for now** (the developer, 2026-11-13). Doctor appointments go to the backlog as a feature the user can switch on (B1). |
| Q5 | How does the app find a moment when the user can act? | **Start with the evening question** from §7 (the developer, 2026-11-13). **No home-screen widget**: the developer does not use widgets. |
| Q6 | Gamification: what kind? | **Several forms, on the forgiving side**, can be switched off (the developer, 2026-11-13). No streak that punishes a bad week. Exact forms are a design question, see F10. |
| Q7 | Main capture path | **A notification that stays at the top** (the developer, 2026-11-13). Reason: capture must not depend on the user remembering that a tool exists; it has to be in view. The quick-settings tile is out for that reason. Long-press on the icon can come along for free. |
| Q9 | How does the app learn that a reply is owed? | **Try auto-detect** through the notification listener (the developer, 2026-11-14). This moves B4 out of the backlog as an experiment on the developer's phone. Agreed under Q2 with this condition (Claude): the listener is an optional part that can be switched off or removed, and "the app asks" stays as the fallback, so a later Play release does not depend on it. |
| Q8 | Pre-filled message texts | **Not for now** (the developer, 2026-11-13). The nudge opens the right chat, empty. |

Also seen by the developer: "friendslist" (small, screenshots not convincing). Not assessed.

## 5. The developer's own situation (answers, 2026-11-13)

- **Main break point: the intention gets lost.** The developer does think of people now and then and wants to contact them, but the thought comes at a moment when acting is not possible. Later, when there is time, the intention is gone. The same happens with doctor appointments. Also true: people not coming to mind at all, not knowing what to write, and forgetting to reply. Guilt after long silence was not picked.
- **Channels:** WhatsApp is the main one; a few people on Telegram and Signal. For most people the real goal is to **meet up** now and then, not to chat.
- **Who:** friends and more distant family. Examples: inviting an aunt and her husband to the new apartment (intended for two years), visiting grandpa.
- **How many:** about 30–40 to start, including loose contacts.
- **Childhood friends:** most can be reached; a couple would have to be found first.

### What this means (Claude, 2026-11-13)

- The core problem is **capture and resurfacing**, not cadence. A thought like "I should invite my aunt" must be caught in a few seconds at the moment it occurs, and brought back at a moment when the user can act. This is a different centre than the competitor apps, which start from "contact X every N weeks".
- Items are **intentions attached to people** ("invite aunt to the apartment", "visit grandpa"), not only "get in touch".
- The end goal is often a meeting, so the flow may need to go past the first message to an agreed date.
- "Forgot to reply" is a second capture case: mark a chat as "owe an answer".
- Finding lost people is a small side case (a couple of people) and can stay out of the first version.
- The same mechanism fits doctor appointments. That is a scope question (Q4), not a reason to widen the app now.

More answers (the developer, 2026-11-13):

- **Free moments are not fixed.** Never during work. Some weekends and weekday evenings have time, others do not, and on some the developer just wants to relax. The open problem is how the app finds out.
- **Tools tried so far:** only notes with a reminder. No personal CRM or to-do app.
- **Birthdays are wanted.** Known birthdays are in the phone contacts and Google Calendar already reminds in the morning. What is missing is an evening follow-up: an interactive notification asking whether the user has congratulated yet.

## 6. Feature candidates

Not a commitment. The design phase picks and orders them.

| # | Feature | Notes |
|---|---|---|
| F1 | Quick capture of an intention for a person | Seconds, from outside the app. "Invite aunt", "write to Tom". |
| F2 | Resurfacing at a moment with time | See §7 and Q5. |
| F3 | People list | 30–40 people, friends and family, imported from phone contacts. Short notes per person. |
| F4 | Start the contact from the nudge | Each person has a **main messenger** stored (WhatsApp, Telegram, Signal, Discord). The nudge opens that chat directly. No pre-filled text (Q8). Discord has no link by phone number; how to open a Discord chat is to be checked. |
| F5 | Birthdays | Read from contacts. Evening notification "Congratulated yet?" with Yes / Open chat / Later. |
| F6 | "Owe a reply" | Capture a chat that needs an answer; comes back like any intention. |
| F7 | Meet-up follow-through | An intention can stay open until a date is agreed, not only until a message is sent. |
| F8 | Gentle "long time no contact" hint | For people who do not come to mind at all. The rhythm comes from the person's class (F9). No overdue counters. |
| F9 | Friend classes | Idea from the developer, 2026-11-13. Roughly: (a) close friends met regularly, also for casual things like sports or gaming; (b) occasional or long-distance friends; (c) people to check in with a couple of times a year. Family fits in too. The class sets the expected rhythm and the kind of contact (meet up vs. message). Names and number of classes are open. |
| F10 | Gamification, can be switched off | Idea from the developer, 2026-11-13: streaks or similar. Concern (Claude): a streak that resets punishes a bad week, which clashes with "Not today costs nothing" (§7) and is a known reason people drop apps. Options: a count that only grows ("14 people reached this year"), a weekly streak with free skip days, or a classic daily streak. Open (Q6). |
| F11 | Ideas per person | Things to do together and things to talk about. Wanted (the developer, 2026-11-14). See §9.8. |
| F12 | Groups | Candidate, possibly later. See §9.8. |
| F13 | Reconnect state | A person is "to reconnect" until the first exchange; one at a time with a self-set week. See §9.8. |

### Backlog (after the first version)

| # | Item |
|---|---|
| B1 | Doctor appointments as a feature the user can switch on (the developer, 2026-11-13). |
| B2 | Help finding old friends whose contact details are missing (a couple of people). |
| B3 | iOS. |
| B4 | ~~Automatic "last heard from" via notification listener.~~ Moved into scope as an experiment by Q9 (2026-11-14). |
| B5 | Suggested or pre-filled message texts (Q8). |

## 7. Finding a moment with time (proposal, Claude, 2026-11-13)

The phone cannot tell "free and willing" from "free and wants to relax". Guessing wrong makes notifications that get swiped away, which is how reminder apps die. So: **ask, do not guess**, and make "no" free.

1. **One evening question** on days that are not ruled out: "Got ten minutes for someone today?" with *Yes* and *Not today*. *Not today* has no cost: nothing becomes overdue, nothing piles up.
2. ~~Home-screen widget showing one open intention.~~ Dropped: the developer does not use widgets. Opening the app itself shows one open intention instead.
3. **Cheap exclusions:** never during working hours (set once, or read from the calendar).
4. **Later:** learn from the answers which days and hours get a *Yes* and shift the question there.

On *Yes* the app shows one intention, not the list.

## 8. Technical findings (2026-11-13)

From a Sonnet subagent's web check. **(U)** marks points it could not confirm from a source; verify these in a prototype before relying on them.

### 8.1 Capture without a widget

| Path | Feasible | Notes |
|---|---|---|
| Long-press icon shortcut | Yes | `quick_actions` (flutter.dev, maintained). Lowest effort. |
| Quick-settings tile | Yes, with native Kotlin | Flutter packages are small and weak; a short `TileService` that opens a capture screen is the solid route. Reachable from the lock screen. |
| Notification with text field | Yes, best effort | `flutter_local_notifications` actions with text input (U). Since Android 14 the user can swipe ongoing notifications away, so re-post on app start and boot. |
| Share from WhatsApp | Partly | An `ACTION_SEND` text target works. WhatsApp shares the selected message text only, no contact identity (U), so the user picks the person in the app. |
| Voice (Assistant/Gemini) | Skip | Unclear status (U), native work, poor fit for a personal app. |
| Lock-screen shortcut slots | No | Limited to system apps (U). |

### 8.2 Notifications

- `flutter_local_notifications` is the pick (active, v23). Action buttons run in a background isolate without opening the app; "Open chat" can open the UI.
- Nudges do not need exact timing, so inexact scheduling is enough. Needs boot receiver. Phone makers' battery savers can drop alarms; ask for a battery-optimisation exemption.

### 8.3 Opening a chat (F4)

| Messenger | By phone number | Pre-filled text |
|---|---|---|
| WhatsApp | `https://wa.me/<number>?text=` (U, not fetched from WhatsApp docs) | Yes |
| Telegram | `tg://resolve?phone=` or `t.me/+<number>` | Yes |
| Signal | `https://signal.me/#p/+<number>` | No (U) |

### 8.4 Contacts and birthdays (F3, F5)

`flutter_contacts` (maintained) reads contacts and their birthday events with `READ_CONTACTS`.

### 8.5 Automatic "last heard from" (possible later feature)

A sideloaded app can use a notification listener to see incoming WhatsApp notifications and record who wrote. Limits (U): incoming only, nothing while the chat is open, muted chats may be missing, group and summary notifications need filtering. Flutter packages are stale; a small Kotlin listener is safer. Needs "Notification access" and possibly "Allow restricted settings". This only works because the app is not published on Google Play, which bears on Q2.

### 8.6 Storage

`drift` (SQLite, active) fits: people, intentions and contact events are relational. `isar` is abandoned. `hive_ce` is maintained but key-value only.

## 9. Evidence on ADHD and friendship rhythms (2026-11-14)

From a Sonnet subagent. It read search snippets only, no full papers. **Overall the evidence is thin:** there are no real-life trials in adults with ADHD of reminders, streaks or message openers. Most design advice below is inference.

### 9.1 What the studies say

- ~~Time-based remembering is the weak spot in adult ADHD; remembering on an outside cue is much less affected.~~ **Corrected 2026-11-14 after reading the full paper, see §9.5.** The linked paper is not a review and its own adult lab data show no such difference. The claim is a summary of earlier studies, several of them on children. https://link.springer.com/article/10.1007/s12402-018-0273-x
- Adults with ADHD carry out fewer real-life intentions, and this is linked to procrastination. https://pmc.ncbi.nlm.nih.gov/articles/PMC10255685
- If-then plans help in lab tasks (children with ADHD; general effect d≈0.65). No adult ADHD field trial found.
- Missing one day does not harm habit formation (Lally 2010, n=96); being very inconsistent does. https://pmc.ncbi.nlm.nih.gov/articles/PMC3505409/
- Friendship: about 50 hours together to become a casual friend, 90 for a friend, 200+ for a close friend (Hall 2018, rough survey estimates). Dunbar's layers of about 5, 15, 50, 150 people, with contact roughly weekly for the inner 5, monthly for the 15, yearly for the 150 (from a newspaper piece by Dunbar; weak).

### 9.2 Blog or company claims only

- Notifications that are always there or always the same get ignored. No study found.
- Broken streak, then shame, then dropping the app. Described by many ADHD blogs, several of them app vendors.
- Tiny first steps, templates and time-boxing lower the barrier to starting. Standard coaching advice, untested.

### 9.3 What follows for the design (Claude, 2026-11-14)

- The approach fits the one solid finding: the app turns "later" (time-based, weak) into an outside cue (the evening question).
- The always-visible capture notification (Q7) will probably fade from attention. Vary its content and test this early.
- "Not today" and one missed day must have no cost. This supports Q6.
- Neutral wording: "Anna came to mind", never "You have not talked to Anna in 94 days". No red badges.
- Seed rhythms for friend classes (F9), editable: close about every one to two weeks, occasional about every four to six weeks, check-in two to four times a year. Derived, not validated.

### 9.4 Discord

Nothing official found (unverified, from the subagent's memory): a link can open a user's **profile** by numeric user ID, not the chat. A direct chat needs the chat's channel ID, copied from Discord with Developer Mode on. Custom links may break with app updates. Fallback: open Discord and let the user find the chat. Test on the phone.

### 9.5 Papers read in full (2026-11-14)

The developer supplied six PDFs (in `docs/papers/`, keep out of git). Sonnet subagents read each in full. Claude spot-checked the Altgassen and Knouse key numbers against the text. Page numbers are in the subagent reports, not repeated here.

**Altgassen, Scheres & Edel (2019), prospective memory and procrastination in adult ADHD.** 29 adults with ADHD, 24 controls. The most relevant paper.

- Lab tasks, time-based and event-based: no difference between groups.
- Everyday life: large difference. Asked to phone the experimenter at an agreed time days later, 52% of the ADHD group never called on time, against 21% of controls.
- Own everyday intentions over three days: the ADHD group **recalled 67% but carried out only 52%**; controls 81% and 81%.
- **The most frequent reason given in the ADHD group for not acting was "did not feel like it".** Forgetting was named about as often as by controls.
- Almost nobody used reminders, so the study says nothing on whether reminders help.
- The ADHD group planned ahead less. The authors point to vividly imagining the future action as a possible aid.

**Occhionero et al. (2023), Sensors.** Pressing a button on a wrist device when getting up. Adults with ADHD 48.5% on time, controls 58.6%, not significant; groups poorly matched. Little use for this app.

**Roberts & Dunbar (2011, 2015).** One study, reported twice: 25 UK students followed for 18 months after leaving school. Not ADHD.

- Closeness to friends fell, closeness to family rose slightly, even where contact with family dropped.
- Being a close or long-known friend gave no protection.
- Both contact and shared activities went with staying close. For men, activities more; for women, contact more (exploratory, n=25).
- New friends went with a bigger drop for old ones.
- No thresholds ("every X weeks is enough") and no comparison of messaging with meeting.

**Knouse et al. (2022), Inflow app for adults with ADHD.** 7 weeks, 205 enrolled. Two authors own the app; users came from its waitlist and were rewarded.

- 36% dropped out before week 2, only 4% after that.
- Median session 3.4 minutes, about four sessions a week.
- Community posting and live events: median use zero.
- Best-rated: easy to understand, easy to use, "helps me remember where I left off".
- Reasons for dropping out were not collected. Reminders and rewards were not analysed.

**Păsărelu, Andersson & Dobrean (2020), review of 109 ADHD apps.** Store listings only, no user data. 16% named any evidence base, none reported efficacy, none personalised, 41% had no privacy policy. Nothing on retention.

### 9.6 What changes (Claude, 2026-11-14)

1. **Remembering is only half the problem.** In the one adult everyday-life study, people with ADHD remembered two thirds of their intentions and still did not act, mostly because they did not feel like it. Capture and resurfacing (F1, F2) get the intention in front of the user. They do not make the user act. The step after "Yes" needs as much design care as the reminder: it must be small, and it should feel good to have done it.
2. This strengthens the case for **rewards** (F10) and for a **tiny first step**. It also puts Q8 (no pre-filled texts) in question, since the developer named "I don't know what to write" as a break point. Not reopened; noted for design.
3. **Friends and family need different defaults** (F9): family on a slower rhythm with less pressure. Rhythm numbers remain derived, not evidence.
4. **Meeting up is its own kind of suggestion** next to messaging (F7), especially as shared activities went with staying close for men.
5. **The first two weeks decide.** First use must work with almost no setup. Sessions should be a few minutes at most. No features that need a crowd.
6. Keep an intention alive after "Not today"; do not let it expire.
7. The app should record its own use (intentions captured, carried out, days answered) so the developer can see after a month whether it works. No paper answers that.

### 9.7 What would make the developer act (answers, 2026-11-14)

- **Something to write about, or the start of a text.** A generic text from the app does not help.
- **A treat in real life** would help. The developer notes an app cannot provide one.

Ideas from this (Claude, 2026-11-14), not decided:

- **Capture the reason with the intention.** What made the user think of the person is the opener ("saw a bouldering video, thought of Tom"). The capture step asks for it in a few words.
- **Share into the app.** A link, photo or video shared from any app becomes an intention for a person: "send this to Tom". The content is the message.
- **One line after each contact** ("new job in March, ask how it goes") gives the next opener.
- **Ideas per person** for meeting up ("bouldering", "show the apartment").
- **Self-set treats.** The user lists real treats; the app says when one is earned (for example after three contacts). Honour system. Ties into F10.

### 9.8 Reconnecting and meeting up (answers, 2026-11-14)

**Old friends**

- What stops the first message: **no urgency.** "We have not talked in three years, one more day or week makes no difference."
- Once in contact: answering these people has low priority, and replies get forgotten for so long that it becomes shameful. Finding what to write is not a problem once the contact has started.
- "Reconnected" means regular contact: more often than birthdays, and a proper meet-up a couple of times a year.
- About 5 people come to mind at once, 10 at most.

**Meeting up**

- Stalls at finding a time (some friends have children now), at finding something to do, and in groups at both, much worse.
- Keeping ideas per person would help (the developer, 2026-11-14).

**What follows (Claude, 2026-11-14), not decided**

- **Reconnecting is a start-up state, not a class.** A person is "to reconnect" until the first exchange, then moves into a normal class (occasional friends). With 5–10 people this is a short list worked through one at a time.
- **The missing urgency needs a small deadline the user sets.** One reconnect person at a time: "This week: Jonas." The evening question puts that person first. A birthday or a captured reason is a natural "why now".
- **"Owe a reply" (F6) is central for these people, not a side feature.** The shame comes from the forgotten reply, so the app must know that a reply is owed. Play-safe way: some days after the user opened a chat from the app, it asks "Did Jonas answer? Do you owe a reply?". The automatic way is the notification listener (B4), which would see that Jonas wrote. That is a reason to reconsider B4, and it stays a discussion point under Q2.
- **Ideas per person** (things to do, things to talk about) become a feature (F11).
- **Finding a time** is a scheduling problem that the app should not try to solve. It can help at the edge: suggest proposing two concrete dates, and keep "waiting for Tom's answer on a date" as an open item that comes back.
- **Groups** (F12, candidate): a group as an entry of its own, linked to a WhatsApp group, with its own ideas and rhythm. Could wait for a later version.

## 10. Open research questions

- Do the ideas in §9.7 and §9.8 fit? Asked 2026-11-14.

- Reconnecting with childhood friends: what has stopped it, what "reconnected" means, how many people. Asked 2026-11-14, not answered yet.
- Meeting up: where arranging stalls; would stored ideas per person help. Asked 2026-11-14, not answered yet.

- How to open a Discord chat with a given person.
- Does a notification that stays at the top hold up in daily use (Android 14+ lets the user swipe it away; people can go blind to it)? Test early in a prototype.
- Is AI drafting of messages wanted, and may friend data leave the phone?
- Verify: Android notification listener and call-log policy; WhatsApp deep links with pre-filled text; reading birthdays from contacts.
