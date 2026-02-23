# Assignment - Bubble Bobble Clone

## How to Run
1. Open the project in Godot
2. Open Main.tscn
3. Press Play

## Controls
### Menu
- Enter / Space = Start game
- R = Restart after Game Over

### Game
- A / Left Arrow = left
- D / Right Arrow = right 
- W / Up Arrow = jump
- Space = fire

## Features Implemented
### Core movement + world (2 pts)
[✓] TileMap platforms with collisions
[✓] Left/right movement
[✓] Jump (with gravity)
[✓] Can’t walk through walls
[✓] Use CharacterBody2D and move_and_slide().

### Bubble shooting (2 pts)
[✓] Player can shoot a bubble in the facing direction
[✓] Bubble travels horizontally, then floats upward
[✓] Bubble has a lifetime (despawns eventually)

### Enemies (2 pts)
[✓] Spawn 3–6 enemies in the level
[✓] Enemies patrol platforms (simple AI: move left/right and turn at walls/edges)
[✓] Enemy damages player on contact (lose health or life)

### Trapping mechanic (2 pts)
[✓] If a bubble overlaps an enemy, the enemy becomes trapped
[✓] Trapped enemy stops acting and becomes attached to the bubble (or replaced by a “trapped bubble”)
[✓] Bubble now floats (or continues floating) with trapped enemy inside

### Popping + scoring + game loop (2 pts)
[✓] Player can pop trapped bubbles by touching them (or pressing an action near them)
[✓] trapped enemy is destroyed
[✓] player gains points
[✓] HUD shows score and lives/health
[✓] When player loses all lives/health → Game Over screen with restart

### Bonus (+1 point)
[✓] Enemy “rage” escape: trapped enemy escapes after N seconds, moves faster

### Feedback polish: VFX + SFX
[✓] Sound effects: Jump, Fire, Pop, Ouch
[✓] Background music
[✓] Player flicker effect
[✓] Player death animation
