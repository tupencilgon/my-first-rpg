# Aster ARPG v2 — Icon-generation record

All files in `assets/arpg_v2/icons/` were generated as individual original PNG assets with the built-in OpenAI image generation tool on 2026-09-22. Each result was visually checked for its requested subject, square 1254×1254 canvas, transparent background, and absence of text/UI panels.

## Shared prompt

```text
Use case: stylized-concept
Asset type: a single game UI inventory/action icon for Aster, dark-fantasy top-down ARPG.
Style/medium: original hand-painted pixel-inspired game art, crisp chunky readable silhouette at 24–48 pixels, tasteful detailed edges, not copied from any game.
Composition/framing: one centered isolated object, square 1:1 canvas, generous transparent padding.
Color palette: muted antique-gold rim/details, slate, worn leather, cold ash; selective orange ember or purple crystal accents only when specified.
Constraints: genuinely transparent background; no UI square, no border, no panel, no text, lettering, numbers, logo, watermark, character, hands, or scenery.
```

## Per-icon subject additions

| File | Subject addition to the shared prompt |
|---|---|
| `sword.png` | A weathered steel sword angled from lower-left to upper-right, wrapped leather grip, a subtle antique-gold guard, small ember glint on the edge. |
| `dodge.png` | A rugged leather boot in a quick forward stride, with a short pale ash-colored swish trail behind it. |
| `nova.png` | A compact radial burst of orange embers and pale ash sparks, magical combat skill effect. |
| `potion.png` | A small round red healing vial with cork and a tiny antique-gold neck band, gentle internal glow. |
| `bag.png` | A compact traveler leather satchel, slate-brown worn leather, antique-gold buckle and a small ash-grey travel tag. |
| `map.png` | A folded weathered parchment map with torn edges, a thin leather tie and tiny antique-gold compass charm; no markings or writing. |
| `shield.png` | A weathered iron round shield, slate metal, dented surface, aged leather straps subtly visible, antique-gold boss. |
| `gold.png` | A small stack of antique gold coins, chunky readable discs with abstract embossed motifs and a warm ember glint; no numbers. |
| `ore.png` | A chunky fractured amethyst ore chunk, slate rock matrix with rich purple crystal facets, tiny ash dust. |
| `hide.png` | A rolled cured hide bundle, warm worn brown leather/fur texture, bound with an antique-gold clasp. |
| `herb.png` | A small sage-green herb sprig, three readable leafy stems, wrapped lightly with thin leather cord. |
| `bow.png` | A simple wooden hunting bow in a poised diagonal, dark ash wood, taut string, subtle antique-gold grip wrapping. |
| `staff.png` | A dark wood magic staff angled upright, capped with a glowing faceted amethyst crystal and a small antique-gold setting. |
| `armor.png` | A compact steel-and-leather chest armor cuirass, slate steel plates, worn dark leather underlayers, antique-gold buckles. |
| `forge.png` | A blacksmith hammer resting diagonally across a small dark iron anvil, restrained orange ember glow at contact point. |
| `quest.png` | A rolled weathered parchment tied with a red wax seal, visibly blank parchment with no writing or symbols. |
| `close.png` | Two simple weathered iron bars crossed as a clean X, square-cut ends, subtle antique-gold rivet caps; no lettering. |
| `settings.png` | One chunky weathered iron cogwheel with eight clear teeth, slate metal, aged antique-gold inner hub; no lettering. |

## Provenance

- Method: built-in `image_gen` (one independent generation request per icon; no source image, no editing script, no CLI fallback).
- Generated originals retained by Codex under `C:\\Users\\PC\\.codex\\generated_images\\01a0c9e7-f61b-7120-a749-593891b4c04c`.
- Project copies: `D:\\GameDev\\projects\\my-first-rpg\\assets\\arpg_v2\\icons`.

## Verified destination mapping (2026-09-23)

The destination files below were opened and visually checked individually after copy. SHA-256 is recorded to pin the checked version.

| File | Observed subject | SHA-256 |
|---|---|---|
| `armor.png` | steel/leather chest armor | `5d46c002365061997584896f0709083e9b7182ca7e98ea9c054e99684d71fdf3` |
| `bag.png` | traveler leather satchel | `646973eeebb260de203d848b2b7a6bd22baadae223464ad2caa7b208384d472c` |
| `bow.png` | wooden hunting bow | `23abcaeb87df999b228a2f50a3e4d6903fafa8ead31815968854b827c18979e2` |
| `close.png` | crossed iron bars X | `3ce9e5b198358f36f8dc6bb12217b1dcd9c6635c1ded82bbfdd9ee871e0e6120` |
| `dodge.png` | leather boot with pale trail | `a8efe30756485c20c8884660b643a2f65e9b92798457599712f86a29380c838a` |
| `forge.png` | hammer on anvil | `0933281602dbea6a6b7f0f2ea2fc604a4448d9e28511120e7f66c031be7e848c` |
| `gold.png` | stack of antique coins | `61968d4828bd7ec1344c3e122a8b7208a2f799d4169248cc81c890a01dd9c4a9` |
| `herb.png` | sage-green herb sprig | `5d11c6e407e3edc0d474b6ca47c1cfd43ff50c0e465c0eb17793aad09e9a9c4d` |
| `hide.png` | rolled cured hide | `fc64b3f27c83e3e4805a5d99b200635ece942e52e717be8fe7bbd0868785b98d` |
| `map.png` | folded parchment map | `020d1395c2b1b4aa9915365e5065cc89753efe2a77c3b191c7345f209a4858f6` |
| `nova.png` | ember radial burst | `18e5f8da95769b879c194cb6e7f7a73040afdc8bef720076059edb8f9a0248f1` |
| `ore.png` | amethyst ore chunk | `bee917f4b4b1c19ae2ff8e63c2935958845301392ce9cdda1d472a60f50353ba` |
| `potion.png` | red healing vial | `ba057bf85b484e27b000dfdcc1449210c895a1a75e94e294f3aa48e063652bff` |
| `quest.png` | blank parchment with red wax seal | `959474347c9a19fd05c8ee77b1cd9021d710e91107d3653626c0a476ab21c27d` |
| `settings.png` | iron gear | `048a1ca2045c62fce18be7ab2df04b7adc7d0087b62eec41c47e4568f1876165` |
| `shield.png` | weathered iron shield | `1f167c6b1ef33be0da6723b5a8e0eed74349d46d0857a419218f71a1a393df74` |
| `staff.png` | amethyst staff | `638da141a8f1b8d509003c804d9c00fc3fb581c415251ea126900552c06d2c55` |
| `sword.png` | weathered steel sword | `c9831ed8354c200cfeee2eac3367e7ae21087865a57ee52e0886d3597383a9bb` |
