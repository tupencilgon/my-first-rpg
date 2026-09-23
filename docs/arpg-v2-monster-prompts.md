# ARPG v2 monster sprite generation record

All seven source sheets were generated with Codex built-in **imagegen** on 2026-09-22. The original outputs are preserved under `C:\Users\PC\.codex\generated_images\01a0c9e7-b787-7700-a686-7d02d9949a50\`. Project copies are in `assets/arpg_v2/monsters/`.

## Shared production contract

Use case: stylized-concept. Asset type: game-ready animated monster sprite sheet for a top-down ARPG. One landscape sheet with genuine transparent alpha background; exact regular 8 columns x 4 rows, no grid lines. Rows: DOWN/front/south, UP/back/north, LEFT/west, RIGHT/east. Columns: idle, walk A, walk B, attack wind-up, attack strike, hurt recoil, dying, dead. Hand-painted dark-fantasy pixel-inspired 2D 3/4 top-down style; muted ash, stone and worn-leather Aster palette with amethyst and ember accents, readable 48–70px silhouette. No text, labels, UI, scenery, floor tile, watermark, overlaps, or cell-boundary contact. Every entity stays centered with a consistent lower-middle anchor and has visibly distinct action poses.

## Subject prompts and provenance

| Project asset | Subject prompt | Built-in original |
|---|---|---|
| `wolf.png` | Sói tro: lean ashen scarred wolf, charcoal-gray fur, ember-red cracked scars, torn ear, low predatory stance; lunging bite and claw swipe. | `exec-88fd3447-0993-4d1f-921e-1a59a535cd32.png` |
| `bat.png` | Dơi hang: dusty violet-brown leathery wings, pale ears, glowing amber eyes; hovering lower wing/body anchor; fast forward wing-and-bite lunge. | `exec-f34b498d-6fd9-45f1-958e-2dc6d9ab30fd.png` |
| `beetle.png` | Bọ tinh thạch: squat purple amethyst crystal beetle, dark chitin body, faceted violet crystal carapace and small glowing cracks; horn/headbutt crystal jab. | `exec-2e654597-976a-436c-8108-a8cc5f72bb2f.png` |
| `bandit.png` | Cướp áo đen: hooded dark-leather bandit, blackened cloth hood, ash-gray scarf, short curved dagger, muted red sash; dagger slash with consistent weapon. | `exec-95db55eb-802f-4ec1-9af6-62c13c890117.png` |
| `wraith.png` | Bóng sương: hooded hollow silhouette of smoky blue-gray spectral vapor, tiny icy-cyan eyes and downward wisps; incorporeal claw thrust. | `exec-bec34e6b-5ee5-416f-bd4a-e75ee9fd6465.png` |
| `crystal_beast.png` | Thú hắc thạch: huge four-legged corrupted crystal beast, black volcanic plates, jagged deep-amethyst crystals, ember cracks; forward crystal-horn slam. | `exec-8bc9ba32-f2fa-44a5-9f69-18ce9c8b3f13.png` |
| `seal_keeper.png` | Người giữ ấn: solemn robed sun-seal guardian, gray stone ceremonial robes, gold sun-seal medallion and staff with warm amber runes; staff casting with a contained amber seal flare. | `exec-a25761a2-0639-4454-9e15-f174fd9bf344.png` |

## Validation result

Every generated file is `1774 x 887`, RGBA (`Format32bppArgb`) with transparent corner pixel alpha `0`, rather than the requested `2048 x 1024`. Each inspected sheet does visibly contain an 8 by 4 regular layout and the intended directional/action sequence. Consumers should calculate cells as `width / 8` by `height / 4` (221.75px), or sample normalized grid regions, rather than assuming 256px cells.

## Direction and crop audit — 2026-09-22

All seven project sheets were manually inspected for directional consistency, transparent padding, cell bleed, and cropping. No significant inter-cell bleed or clipped pose was found. The first wolf output had two confirmed wrong-direction cells: row 3 (LEFT), column 5 (attack strike) and column 6 (hurt recoil) faced right. A targeted built-in imagegen edit corrected them; `wolf.png` now comes from `exec-915cf286-f43f-4620-8390-4f712b6671c1.png`, retaining `1774 x 887`, RGBA transparency, and the 8x4 layout. The superseded source file remains in the built-in generated-images folder.

Some UP-row attack/cast poses use a modest profile turn (not a reversed base direction), especially wolf row 2 columns 4–5 and the bandit/seal keeper attack actions. Render these authored frames as-is; do not apply automatic horizontal flips to them.
