# PROMPTS.md — GenAI Asset Replacement (Bubble Bobble Clone)

Project Theme
- Scene: Spooky underground mine
- Player: Miner character (cute pixel-art style, side view)
- Enemy: Shadow creature with clear silhouette
- Projectile: Dream bubble projectile
- Tiles: Stone blocks
- Visual Style: 16-bit / 32-bit pixel art, low saturation, cool lighting, consistent palette

---

## Tools Used
### Image Generation
Tool: ChatGPT Image Generation (OpenAI)
Used for:
- Background
- Player sprite sheets
- Enemy sprite sheets
- Projectile sprite
- Stone tileset

### Sound Effects
Tool: ElevenLabs
Used for:
- Jump grunt
- Hurt sound
- Bubble shooting sound
- Bubble pop sound
- Enemy death sound

### Music
Tool: Mureka AI Music Generator
Used for:
- Background music

---

## 1) Background (800×450)
**asset_id:** bg_mine_800x450
**type:** bg
**prompt:**
"""pixel art background, spooky abandoned mine tunnel, side-scrolling platformer backdrop,
low saturation, cold lighting, subtle fog, wooden supports, stone walls, depth layers,
16-bit retro game style, clean pixel edges, no characters, no text, 800x450 composition"""
**negative:**
"""text, logo, watermark, modern UI, blurry, photorealistic"""
**iterations:** 3–6  
**notes:** Needs depth layering in the background, but should not distract from the player; 
a slight vignette is acceptable.

---

## 2) Player (Miner) Idle Sprite Sheet (4 frames, 256×64, each frame 64×64)
**asset_id:** player_idle_sheet_4f_64  
**type:** sprite_sheet  
**prompt:**
"""pixel art miner character sprite sheet, side view, cute but readable silhouette,
helmet with small lamp, simple backpack, 4-frame idle animation,
grid sprite sheet layout: 1 row x 4 columns, each frame 64x64,
transparent background, consistent proportions, consistent palette,
16-bit retro arcade style"""
**negative:**
"""extra limbs, changing outfit between frames, inconsistent size, blur, anti-aliasing, background"""
**iterations:** 5–10  
**seed/settings:** Use a fixed seed if available
**post-edit:** Align the helmet lamp position, align the character’s feet to the same pixel baseline, 
remove stray pixels around edges.

---

## 3) Player Run Sprite Sheet (4 frames, 256×64, each frame 64×64)
**asset_id:** player_run_sheet_4f_64  
**type:** sprite_sheet  
**prompt:**
"""pixel art miner character sprite sheet, side view, 4-frame running cycle,
grid sprite sheet layout: 1 row x 4 columns, each frame 64x64,
transparent background, consistent character with player_idle (same helmet lamp and colors),
clear leg motion, clean pixel edges, 16-bit retro arcade style"""
**negative:** Same as above
**iterations:** 5–12
**notes:** Running left/right usually uses the same right-facing animation with Flip H in Godot. 
The hitbox must remain unchanged.
---

## 4) Enemy (Shadow) Run Sprite Sheet (4 frames, 256×64, each frame 64×64)
**asset_id:** enemy_shadow_run_sheet_4f_64  
**type:** sprite_sheet  
**prompt:**
"""pixel art shadow enemy sprite sheet, side view, 4-frame run animation,
silhouette made of dark smoke, faint purple highlights, glowing eyes,
grid sprite sheet layout: 1 row x 4 columns, each frame 64x64,
transparent background, consistent style with the miner sprites, clean pixel edges"""
**negative:**
"""too detailed, photorealistic, background, inconsistent size, messy outline"""
**iterations:** 4–10  
**notes:** The silhouette must be clear so the player can immediately recognize it as an enemy; 
align the feet to the same baseline.

---

## 5) Projectile (Dream Bubble) Flying Sprite Sheet (3 frames, 96×32, each frame 32×32)
**asset_id:** projectile_dream_bubble_sheet_3f_32  
**type:** sprite_sheet  
**prompt:**
"""pixel art dream bubble projectile sprite sheet, 3-frame looping animation,
glowing bubble with dreamy swirls, subtle sparkles, 1 row x 3 columns,
each frame 32x32, transparent background, clean pixels, retro arcade style"""
**negative:**
"""text, logo, background, blur, inconsistent bubble size"""
**iterations:** 3–8  
**notes:** Keep the outer bubble shape consistent across frames; 
only animate highlights or inner swirl to avoid jitter.

---

## 6) Tileset (Stone) (recommended: 32×32 seamless tiles, at least 8–16 tiles arranged in a grid)
**asset_id:** tileset_stone_32  
**type:** tileset  
**prompt:**
"""pixel art stone tileset for platformer, 32x32 seamless tiles, rocky mine stones,
includes: solid block, top edge, side edge, corner, decorative cracked stone,
consistent palette with mine background, clean pixel edges, no seams,
tiles arranged in a neat grid sprite sheet, transparent background"""
**negative:**
"""visible seams, blurry, photorealistic, text, watermark"""
**iterations:** 6–15  
**post-edit:** Must check that every tile edge is seamless; manually fix 1–2 pixel seams if necessary.

---

## Background Music (spooky, loopable, 30–60 seconds)
**asset_id:** bgm_spooky_mine_loop  
**type:** music  
**prompt:**
"""spooky ambient chiptune for an abandoned mine, slow tempo, minor key,
subtle dripping echoes, low drones, retro arcade feel, loopable, no vocals"""
**iterations:** 2–6  
**post-edit:** Apply crossfade between start and end to ensure seamless looping; remove any click artifacts.

---

## B) Shooting (bubble blowing)
**asset_id:** sfx_shoot_bubble  
**type:** sfx  
**prompt:**
"""short retro game sound effect: blowing a bubble, soft 'puff' with a light airy pop,
0.2-0.4 seconds, no reverb tail"""
**iterations:** 2–5

---

## C) Jump (miner grunt)
**asset_id:** sfx_jump_grunt  
**type:** sfx  
**prompt:**
"""short human-like grunt for jump, 'hm!' style, cartoony, not scary,
0.15-0.25 seconds, clean, no background noise"""
**iterations:** 2–6  
**note:** If the tool cannot generate human voice sounds, 
replace with a short tonal “jump sound” and explain the limitation.

---

## D) Hurt (pain shout)
**asset_id:** sfx_hurt_ouch  
**type:** sfx  
**prompt:**
"""cartoon hurt voice: 'ow!' or 'aah!', short and clear,
0.2-0.5 seconds, no background noise"""
**iterations:** 2–6

---

## E) Projectile Break (bubble popping)
**asset_id:** sfx_bubble_pop  
**type:** sfx  
**prompt:**
"""bubble pop sound effect, crisp pop with tiny sparkle, 0.1-0.2 seconds,
retro game style, no long tail"""
**iterations:** 2–5

## F) Ghost Dissolve (enemy defeated)
**asset_id:** sfx_ghost_dissolve
**type:** sfx
**prompt:**
"""ghost dissolve sound effect, eerie soft whoosh with faint whisper fade,
spooky vapor-like disappearance, 0.2-0.4 seconds,
retro arcade game style, no long tail"""
**iterations:** 2–5

---
