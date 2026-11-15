# UI style

The look of the app, written so it can be rebuilt in code and reused for another app. It describes concept V6 with the V6b tweaks (see [02-design.md](../02-design.md) §6.6 and §6.11). Reference pictures: `docs/concepts/previews/v6-*.png`, `v6b-*.png`. Reference source with every value: `docs/concepts/gen_v6.py`.

Status: taken from the concept screens. Not yet built in Flutter, not yet checked on a phone.

## 1. The idea in one paragraph

Material 3 Expressive as the base (tonal surfaces, big round containers, pill buttons), made friendlier with three things: a **hard shadow** under everything you can touch or pick up, a **slight tilt** on small things, and **colourful flat icons**. It should feel like a tidy desk with a few stickers and notes on it. Mature first, playful second.

## 2. Rules

1. **Dark is the main theme.** Light exists and uses the same structure.
2. **Colour sits on small things.** Large areas are neutral or a deep (dark) or pale (light) tone. Bright accents are for buttons, avatars, date badges, stamps, tags and notes.
3. **Hard shadows, no blur.** A shadow is a solid offset shape below the element, never a soft glow. No outlines around elements.
4. **Large things are straight, small things may tilt.** Cards, lists, buttons and inputs are never rotated. Tags, date badges, sticky notes and stamps are tilted by 2 to 9 degrees, alternating left and right.
5. **One celebration.** Confetti appears only when the user confirms a contact. Nowhere else.
6. **No emoji.** Icons are our own colourful set ([icon-style.md](icon-style.md)) or plain Material Symbols Rounded.
7. **Neutral words, no red for blame.** Nothing is shown as overdue. Coral is the action colour, not a warning.

## 3. Colour

### Accents (same in both themes)

| Name | Value | Used for |
|---|---|---|
| coral | `#FF8A7A` (edge `#C4564A`) | main buttons, stamps, the "pick" tag |
| sun | `#FFCF5C` (edge `#C4962A`) | selected state, capture, treats |
| mint | `#7EDDBE` | progress, meet-ups, switches |
| lilac | `#C3B4FF` | getting back in touch |
| sky | `#8CCBFF` | calls, dates, family |
| pink | `#FF9EC6` | birthdays |
| on-accent | `#1F1326` | text and icons on any accent |

Text on an accent is always the dark on-accent colour, in both themes.

### Dark theme

| Token | Value | Used for |
|---|---|---|
| ground | `#17121C` | screen background, input fields inside cards |
| surface | `#231C2A` | cards, list rows, navigation bar |
| surface high | `#30273A` | grey buttons, quote bubbles, selected nav pill |
| grey button edge | `#08060B` | hard shadow under grey buttons |
| shadow | black at 50 % | hard shadow under cards, badges, tags, notes |
| text | `#EFE3F2` | |
| muted text | `#BBADC2` | secondary lines, labels |
| line | `#54475E` | timeline line, dashed borders, dividers |

Tonal containers (a deep version of an accent, with light text of the same hue):

| Tone | Background | Text |
|---|---|---|
| sun | `#46380F` | `#FFE29A` |
| mint | `#12433A` | `#A6F0D8` |
| lilac | `#352B63` | `#DCD3FF` |
| pink | `#54213A` | `#FFC4DC` |
| sky | `#173F5E` | `#BFE2FF` |
| coral | `#5A231C` | `#FFC2B8` |

### Light theme

| Token | Value |
|---|---|
| ground | `#FFF6EA` |
| surface | `#FFFFFF` |
| surface high | `#F3E6D6` (edge `#D9C7B2`) |
| shadow | `#2A1B3D` at 20 % |
| text | `#2A1B3D` |
| muted text | `#6B5A7A` |
| line | `#CDBBA8` |

Tonal containers in light are pale: sun `#FFE08A`, mint `#BDEFDD`, lilac `#DDD4FF`, pink `#FFD0E2`, sky `#C6E5FF`, coral `#FFC9C0`, all with the normal text colour.

## 4. Type

- **Outfit** for headings, buttons, tags, labels and numbers. Weights 600 and 700.
- **Roboto** for everything else. Weights 400, 500, 700.

| Role | Font | Size | Weight |
|---|---|---|---|
| Screen title | Outfit | 30 | 700 |
| Card title | Outfit | 21 | 600 |
| Button | Outfit | 17 | 600 |
| Body | Roboto | 16 | 400 or 500 |
| Secondary | Roboto | 14 | 400, muted |
| Section label | Outfit | 13 | 600, upper case, letter spacing 0.08 em |
| Big number | Outfit | 68 | 700 |

## 5. Shape and spacing

- Screen padding 16 at the sides, 22 at the top. Gap between blocks 14, inside a card 12.
- Corner radius: card 28, small card or list row 20 to 22, button 26 (a pill at height 52), icon button 18, tag 14, date badge 18, input 26.
- Touch targets are at least 44 high. Main buttons are 52.

### Hard shadow

| Element | Offset down | Colour |
|---|---|---|
| Card | 5 | shadow |
| List row, date badge, small card | 4 | shadow |
| Tag | 3 | shadow |
| Coral button | 4 | coral edge |
| Sun button | 4 | sun edge |
| Grey button | 4 | grey button edge |
| Avatar, stamp, colourful icon | 2 to 3 | black at 30 to 40 %, as a drop shadow that follows the shape |

Dashed "empty" things (add a note, empty stamp slot, undated plans) have no shadow.

## 6. Components

- **Card.** Surface colour, radius 28, padding 16, shadow 5. A tonal card uses a tonal container and marks a kind of content: sun for capture and treats, mint for the yearly count and a person's header, lilac for getting back in touch, sky for dates and questions about meeting, pink for small summaries.
- **Main button.** Coral pill, 52 high, dark text, optional icon on the left. One per card at most.
- **Grey button.** Surface-high pill or rounded square (52 × 52, radius 18) for secondary actions and icon buttons.
- **Chip.** 44 high, radius 14, thin border in the text colour, transparent. Selected: sun fill, dark text, no border.
- **Tag.** Small Outfit text on an accent, radius 14, shadow 3, tilted 2 to 3 degrees. Marks state ("Tonight's pick", "Close friend").
- **Avatar.** The person's initial in Outfit 700 on an accent, in one of four shapes: scalloped circle with eight lobes, rounded square (radius 34 %), leaf (round with one tighter corner), arch (round top, tighter bottom). Shape and colour are fixed per person. Small hard drop shadow.
- **Date badge.** 56 × 58, radius 18, accent fill, weekday in small caps over the day number, tilted 2 to 3 degrees, shadow 4.
- **Timeline (Upcoming).** A 2 px line in the line colour runs behind the date badges. Each entry is a date badge plus a list row with title, one muted line and a colourful icon on the right. Section labels ("This week") sit on the line with the ground colour behind them.
- **Compact timeline (per friend).** No cards. Each row: date in small caps on the left (a small tilted accent pill for upcoming dates, plain muted text for the past), a 22 px colourful icon on the line, then one line of text and an optional muted note. A "Today" label divides upcoming from history.
- **Sticky note.** 106 × 88, accent fill, corners 6 except bottom right 22, shadow 5, tilted 1 to 3 degrees. For ideas.
- **Stamp card.** A sun tonal card. Stamps are coral scalloped circles (56) with a dark check, each tilted between 3 and 9 degrees in alternating directions and sitting in place. An empty slot is a dashed ring.
- **Week row.** Seven circles of 36: a deep-mint circle with a star for a day with contact, a plain surface-high circle for "not today", a dashed ring for days to come.
- **Navigation bar.** Surface colour, four destinations, colourful icon (26) over a 12 px label. The active one has a surface-high pill (64 × 36) behind the icon and a bold label.
- **Switch.** 52 × 32 pill, mint when on with a dark knob, surface-high when off with a muted knob.
- **Segmented choice.** Ground-coloured track, radius 14; the chosen segment is a sun pill with dark text.
- **Notification.** Standard Android notification with two or three text actions. Not styled by the app beyond icon and text.
- **Confetti.** About sixteen small dots and short bars in the six accents, scattered around the avatar at the top of the "Nice one" screen.

## 7. Reusing this for another app

Keep sections 2, 4, 5 and the shadow table as they are. Swap the six accents and the two grounds for the other app's colours, keeping the pattern: one bright accent per meaning, a deep and a pale tone of each for containers, one dark text colour on all accents. Draw icons to [icon-style.md](icon-style.md).

## 8. Open

- How this maps onto `material_3_expressive` widgets and Flutter's `ThemeData`. To be worked out in M0 and written into 04-architecture.md.
- Motion (how the confetti, stamps and buttons move) is not designed.
- Contrast of muted text on tonal containers has not been measured.
