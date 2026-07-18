# Gemini Asset Brief — Tactical Mech Shooter

Use this document together with [`tools/visual_asset_descriptions.toml`](tools/visual_asset_descriptions.toml). The TOML file is the asset list: every `[[asset]]` record is one separate image request and its `description` is the subject-specific part of the prompt. Do not combine multiple records into a sheet, a collage, or a single image.

## Master direction

Create **one isolated game sprite** for the named asset. It is for a 2D tactical shooter viewed directly from above, as if an orthographic camera is looking straight down at a tabletop battlefield. There is no horizon, ground plane, perspective foreshortening, character portrait angle, or side elevation.

The finished art must be crisp pixel art with a transparent alpha background. Use a deliberately limited palette: a very dark navy or charcoal outline, two or three material shades, one bright faction accent, and a small number of near-white specular pixels. Build the silhouette from clean blocks and clusters, not soft airbrush gradients. Add visible 1-pixel dark outlines around the outer silhouette and between important mechanical parts. Lighting comes from the upper left: top-left edges are brighter; lower-right seams are darker. Do not draw text, letters, numbers, logos, UI borders, drop shadows, a floor, grid, smoke, muzzle flash, pilot, or a background circle unless the asset type specifically requires it below.

Read the matching TOML `description` literally. It supplies the identity, materials, palette, silhouette and recognisable details. Preserve those differentiators: a medic must have a clearly visible medical marker shape, a flame weapon must have heat hardware, an organic unit must not look like a welded modern vehicle, and alien equipment must use angular crystalline geometry rather than conventional guns. Keep all identifying details large enough to survive the final pixel resolution.

Generate at 4× or 8× the target canvas while keeping every edge aligned to an integer pixel grid, then downsample with nearest-neighbour only. The delivered PNG must have the exact canvas and transparent padding stated below. Never anti-alias or blur the sprite.

## Coordinate system and how the game assembles a mech

In the source images, **right (+X) is the mech's front** and **left (-X) is its rear**. The game rotates the assembled unit as one object in the world.

1. The backpack is drawn first, behind the corpus, to the left/rear of the body.
2. The left and right weapons are drawn next, above and below the body on the Y axis. Their barrels must point right/forward.
3. The corpus is drawn last at the centre and hides the inner mounting ends of the backpack and weapons.

Therefore, show only the outer readable part of a backpack; its right-facing attachment edge may be partly hidden by the corpus. Weapons need a compact stock or coupling at their left end and the clearly readable barrel, blade, emitter, or muzzle at their right end. Do not place an entire backpack or weapon inside the corpus sprite.

## Exact output contracts

| Asset category | Canvas | Position and scale | Required composition |
|---|---:|---|---|
| Race icon | 64×64 px | Centre the icon in a 52×52 px safe area; keep at least 6 px transparent margin | A simple, instantly recognisable faction emblem. It is an icon, not a unit sprite. Use the faction palette and its central symbol from the description. |
| Corpus / chassis | 96×96 px | The circular frame is centred at (48,48), outer radius 46 px. Put the actual chassis inside it, normally spanning 64–80 px wide. | The circular frame is mandatory and rotates with the mech. It must be a solid dark rim and a faction-coloured inner disc, with the chassis readable above it. Show the front at the right, rear mounting plate at the left, and two small side hardpoint hints around Y=26 and Y=70. |
| Weapon | 96×40 px | The complete weapon spans roughly X=8–92 and Y=5–35. Keep 3–5 px transparent padding. | Horizontal top-down equipment; stock/coupler on the left, working end on the right. Give each weapon a unique silhouette appropriate to its type: barrel count, blade profile, coil, drum, crystal, missile tube, nozzle, etc. |
| Backpack | 64×64 px | Centre the module in X=14–50 and Y=10–56; leave transparent edge padding. | Rear-mounted module. The attachment side faces right toward the corpus. Thrusters point left/rear; antennae, tanks, drones, shield emitters, crystals, or organic sacs must follow the matching description. |

For corpus sprites, do not replace the circular frame with a square panel, ground decal, full portrait, or opaque background. The disc is a mechanical turntable / combat base, not a UI badge: it needs a dark 3 px outer rim, a flat but subtly shaded faction-coloured interior, and no glow beyond its edge. The chassis must remain visibly distinct from the disc through a dark outline and value contrast.

## Faction language

- **modern_light**: human personnel mechs and hand-carried gear. Slim biped or powered-armour proportions, practical blue/cobalt plates, small amber service details, cyan optics, compact moving joints and readable tools.
- **modern_heavy**: military vehicles. Wide, low and heavy silhouettes; tracks, wheels, armour slabs, vents, hatches, turrets, grilles and yellow/orange safety markings. They must feel massive from directly above.
- **organic**: grown bioforms. Asymmetrical but readable chitin, muscle fibres, sacs, spines, claws and wet luminous nodes. Use earthy greens/browns with acidic or bioluminescent accents; no manufactured bolts, tracks or clean steel panels.
- **alien**: off-world engineered forms. Symmetrical angular violet/dark shells, cyan crystal cores, magenta energy seams and floating or sharp faceted components. Avoid recognisable human gun anatomy unless the individual description asks for it.

## Prompt format for Gemini

For each entry in `visual_asset_descriptions.toml`, paste this complete prompt, replacing the bracketed parts. Use the asset's own `description` verbatim in the final line.

```text
Create exactly one transparent-background pixel-art game sprite, not a sheet and not a scene.
Game: Tactical Mech Shooter. Camera: strict orthographic top-down view, zero perspective.
Asset category: [race icon | corpus | weapon | backpack]. Asset name: [name]. Faction: [race].
Canvas: [the exact size from the table]. Pixel treatment: crisp 1-pixel outline, limited palette,
integer-aligned clusters, upper-left highlights, lower-right shadows, no antialiasing, no text,
no logo, no floor, no UI, no cast shadow, no background.
Placement: [copy the relevant category rule from the table].
Assembly orientation: right is forward; left is rear. [For weapons: muzzle/working end points right.]
[For corpora: include the mandatory circular 96×96 combat-base frame centred at (48,48).]
[For backpacks: make the right edge the attachment edge that will be partly covered by the corpus.]
Subject brief: [paste this asset's TOML description verbatim].
Return only the isolated sprite with alpha transparency.
```

## Acceptance check before exporting

- Is it one asset only, with transparent pixels outside the silhouette?
- Is the view directly from above and usable after a full 360° rotation?
- Is the subject recognisable at native size without reading a label?
- Does the silhouette and palette match its specific TOML description and faction?
- Does the canvas exactly match its category, with safe transparent padding?
- For a corpus: is the entire unit contained in the mandatory circular frame?
- For a weapon: does the working end point right and is its left attachment end compact enough to sit under the corpus?
- For a backpack: does its attachment edge face right and does it read as a rear module rather than a second body?
- Is it true pixel art: no blur, no semi-transparent fringe, no photorealism and no perspective?

Save the result under the exact `asset_path` from the TOML record, changing only `.svg` to `.png` for a final raster replacement. Keep the SVG source as the editable art source beside it.
