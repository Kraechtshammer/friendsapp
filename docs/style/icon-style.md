# Icon style

How the app's colourful icons are drawn, so new ones match. Decided on 2026-11-15: the app uses its own icons (see [02-design.md](../02-design.md) §6.13). The first fifteen are in `docs/concepts/gen_v6.py` (the `ICONS` table) and can be seen in `docs/concepts/previews/icon-compare.png`, top row.

The style follows the feel of the ENIX launcher icon pack the developer likes: flat, vivid, no background shape. Our icons are drawn from scratch and copy none of its artwork.

## 1. The look

- **Flat.** Solid fills only. No gradients, no blur, no texture.
- **No outline.** Shapes are separated by colour, never by a stroke around them.
- **No background shape.** The object stands alone, with no circle or square behind it. The exception is messenger stand-ins, which copy the form of an app icon (rounded square).
- **Colourful where it helps.** The app is colourful and so are its icons. Most icons need only a main colour, its darker tone, one accent and white; an icon may use more palette colours when the object is colourful itself (changed on 2026-11-18, the developer).
- **Chunky and round.** Corners are rounded. Details smaller than about 3 units on the 48 grid are left out.
- **One object, seen from the front.** No perspective, no scenes, no people's faces.

## 2. Grid

- Canvas 48 × 48. The object fills it to about 2 to 4 units from the edge.
- Shown at 22 to 36 px in the app. It must still read at 22.
- Visual weight is centred. Tall objects (cake with candle) may touch top and bottom; wide ones (phone handset) run corner to corner.

## 3. Shading

Depth comes from one darker tone, used in one of two ways:

- **Split:** the right half or the lower right triangle of the main shape is the darker tone (house body, dice, chat bubble, leaf, front mountain).
- **Layer:** a smaller shape in the darker tone sits on or behind the main one (the inner disc of the stamp, the back mountain in a different hue).

Light always comes from the upper left. Never shade both ways in one icon.

## 4. Palette

| Colour | Main | Dark | Light |
|---|---|---|---|
| Blue | `#2F7BFF` | `#1B55D9` | `#8CC4FF` |
| Green | `#1FD67A` | `#0FA85C` | |
| Yellow | `#FFC61A` | `#F59A0B` | `#FFE08A` |
| Orange | `#FF8A1F` | | |
| Red | `#FF3D5A` | `#D4213F` | |
| Purple | `#8A3FFC` | `#6325C9` | |
| Pink | `#FF4FA3` | `#E0308A` | `#FFE1EE` |
| Teal | `#14C8C8` | | |
| Slate | `#A9B6E8` | `#4A5578` | |
| Paper | `#F1F3FF` | `#D5DAF0` | |
| White | `#FFFFFF` | | |

These are more saturated than the UI accents on purpose, so icons stand out on both the dark and the light ground. Slate replaces black and grey. There is no pure black.

Choose the colour by what the thing is, not by where it is used: plants green, food warm colours, water and sky blue, tools slate. The same icon looks the same everywhere.

## 5. Construction

- Build from simple shapes: rounded rectangles, circles, triangles, thick lines with round ends.
- Round the corners of polygons by giving them a stroke in their own fill colour (width 3 to 4, round joins). This is the only use of strokes besides line-shaped objects.
- Line-shaped objects (check mark, phone handset, magnifier handle) are a single stroke of width 7 to 9 with round ends.
- Small white dots or bars carry meaning (the pips of a dice, the dots in a chat bubble). Minimum radius 3.
- In the app each icon gets a hard drop shadow: 2 px down, black at 30 %, following the icon's shape. The shadow is added by the app, not drawn into the icon.

## 6. The first set

| Icon | Built from |
|---|---|
| home | Yellow body with orange right half, red roof, slate door |
| cottage | Same house in paper white with blue roof and yellow door |
| calendar | Paper sheet with grey right-bottom part, red header, two slate rings, four dots |
| people | Purple person behind a yellow and orange one, each a circle over a half-round body |
| stamp | Green scalloped circle, darker green disc, white check |
| cake | Pink block with darker right half, pale icing with drips, blue candle, yellow flame, slate plate |
| mountain | Teal peak behind a green peak with a darker right side and a white cap |
| phone | Thick blue arc with a lighter round end at each tip |
| dice | Purple rounded square, darker lower right triangle, three white pips on the diagonal |
| chat | Green bubble with a tail at the lower left, darker right half, three white dots |
| check | A single thick green check |
| gear | Slate scalloped circle with a dark slate centre |
| search | Light blue lens with a blue rim and a yellow handle |
| popcorn | Red bucket with two white stripes, yellow and pale yellow puffs on top |
| star | Yellow five-point star with rounded tips |
| leaf | Green leaf, darker lower right half |

Messenger stand-ins copy the form of an app icon (a rounded square with one white symbol) and are drawn in this style, not read from the phone (changed on 2026-11-18, 02-design.md §8). They are stand-ins, not copies of the brands' logos.

## 7. Checklist for a new icon

1. Is it one object, recognisable at 22 px?
2. All colours from the palette, and no more of them than the object needs?
3. One darker tone, light from the upper left, shaded by split or by layer?
4. No outline, no gradient, no background shape, no black?
5. Rounded corners, no detail under 3 units?
6. Put it next to the existing set on a dark and a light ground: same weight, same size?

## 8. For a future icon-drawing skill

Input: the concept ("gift", "coffee"), optionally a colour. Output: one SVG, viewBox `0 0 48 48`, no `width` or `height`, no `<defs>`, no ids, no text, fills from the palette. Then render it at 26 px beside the existing set on both grounds and check it against section 7 before adding it to the set.

Added on 2026-11-16 for the class badge: sprout (green stem, two leaves, the right one darker), bud (the same lower down, with a pink bud split into a darker right half), flower (six pink petals, the right ones darker, yellow centre, stem with one leaf).

Added on 2026-11-16: signal, discord (messenger stand-ins) and gift.

Added on 2026-11-18, messenger stand-ins for the chat app list (drafts and previews in `docs/concepts/messenger-icons-v1/`): threema (bubble with a padlock), line (bubble with two bars), viber (handset), messenger (bubble with a zig-zag), instagram (camera), element (ring with a dot), snapchat (ghost, right half shaded), teams (two people behind a dark tile with a T; draft `teams-b`), slack (four coloured bars turning around the centre on dark purple; draft `slack-c`), linkedin ("in" from shapes), sms (bubble with three dots). Slack uses four palette colours (blue, green, yellow, red), like the colourful brand mark it stands in for.

Added on 2026-11-18 for meetup activities (drafts, the board script and the canvas rows in `docs/concepts/meetup-icons-v1/`): beer (yellow glass, white foam), meeple (purple die with a red pawn), climber (purple figure on two holds), ticket (red stub), clapper (slate clapperboard), notes (two purple beamed notes), guitar (orange body, slate neck), pot (red pot, steam), tools (crossed hammer and screwdriver), dumbbell (blue plates, slate bar), microphone (slate head, pink handle), plate (paper plate with a steak and a leaf, fork and filled knife), bag (pink shopping bag), runner (blue figure mid-stride). Figures are a circle head with thick round-capped limbs, far-side limbs in the darker tone.

Still to draw for the app: the icons for anything new that milestones bring (idea or note, treat types, "they wrote", voice message).

Added on 2026-11-23 (drafts and board in `docs/concepts/activity-icons-v2/`; the developer chose swimmer-c, racket-c and dancer-d): swimmer (teal crawl figure over two blue waves), racket (green tilted oval frame, slate handle that stops at the frame, yellow ball), dancer (a couple, pink and yellow, leaning in with raised joined hands; each figure's limbs in its own darker tone).

Added on 2026-11-23 (drafts in `docs/concepts/activity-icons-v3/`; the developer chose bike-a, football-b, trip-a): bike (orange frame, slate wheels), football (red figure kicking a small white ball), suitcase (purple case with darker straps, slate handle and wheels; for a trip).
