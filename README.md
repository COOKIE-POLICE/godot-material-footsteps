
---

## Godot Material Footsteps
A Godot 3D addon for automatically playing footstep sounds based on the material a character walks on. This addon uses a simple meta data solution.

---

## Table of Contents

- [Godot Material Footsteps](#godot-material-footsteps)
- [Table of Contents](#table-of-contents)
- [How It Works](#how-it-works)
- [Editor Properties](#editor-properties)
- [Usage](#usage)
  - [Auto Play](#auto-play)
  - [Manual Play](#manual-play)
- [Material Detection System](#material-detection-system)
- [Support](#support)

---

## How It Works

* Uses a **RayCast3D** to detect whatever your character is stepping on.
* Checks for metadata on the collider, its children, and its parents.
* Looks for a material name matching what you defined.
* Plays a random sound from the matching list.
* Falls back to a default sound if no material is found.

---

## Editor Properties

**Core Settings**

* `material_footstep_sound_map`: List of `MaterialFootstepSound` resources.
* `default_material_footstep_sound`: The fallback sound if no match is found.
* `target_character`: The `CharacterBody3D` whose movement is tracked.
* `accepted_meta_data_names`: Metadata keys to check (default: `["surface_type"]`).

**Auto Play Settings**

* `auto_play`: If true, footsteps play automatically.
* `auto_play_delay`: Time (in seconds) between each footstep.

**Debug Settings**

* `debug`: If true, debug logs print to console.

---

## Usage

### Auto Play

Enable `auto_play` and set your desired delay via `auto_play_delay`. Footsteps will trigger automatically while the character moves and is not falling.

### Manual Play

If you prefer full control, call `play()` whenever you want.
This is especially useful if you want to play it during specific key frames on an animation. Just remember to turn off auto_play.

```gdscript
$MaterialFootstepPlayer.play()
```

---

## Material Detection System

When a footstep should play:

1. The RayCast3D checks for a collider.
2. The system looks for metadata using keys listed in `accepted_meta_data_names`.
3. It searches:

   * On the collider.
   * In its children.
   * In its parents.
4. If a matching material name exists in `material_footstep_sound_map`, a sound is chosen randomly from that material's sounds.
5. If no match is found, the `default_material_footstep_sound` is played.

---

## Support

Star this repository... I guess.

---
