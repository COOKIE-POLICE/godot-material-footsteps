
---

## Godot Material Footsteps


<p align="center">
  <img src="addons/godot_material_footsteps/assets/editor_icons/icon.png"alt="Godot Material Footsteps Icon", width="128"height="128"/>
</p>

A Godot 3D addon for automatically playing footstep sounds based on the material a character walks on. This addon uses a simple meta data solution.

[Check it out on Godot Asset Library!](https://godotengine.org/asset-library/asset/4122)

---

## Table of Contents

- [Godot Material Footsteps](#godot-material-footsteps)
- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Editor Properties](#editor-properties)
- [Support](#support)

---

## Usage

[![Video Tutorial](https://img.youtube.com/vi/zFgYhZyGRw0/hqdefault.jpg)](https://youtu.be/zFgYhZyGRw0)


To use this addon, follow these steps:

1. In your player scene:
   * Add a `MaterialFootstepPlayer3D` node pointing downward under your character’s foot or base.
2. In the Inspector for the `MaterialFootstepPlayer3D`:
   * Set `target_character` to your player’s `CharacterBody3D`.
   * Fill in `material_footstep_sound_map` with `MaterialFootstepSound` resources mapping material names to sound lists.
   * Set a `default_material_footstep_sound`.
   * Optionally adjust `accepted_meta_data_names` (defaults to `["surface_type"]`).

3. In your level scene:
   * Select any floor (e.g. `StaticBody3D` or any ancestor or descendant of that `StaticBody3D`).
   * In the Inspector, under **Metadata**, add a new key-value pair:
	 * Key: `surface_type`
	 * Value: e.g. `"Grass"`, `"Wood"`, `"stone"` — matching the names in your `material_footstep_sound_map`.

---

## Editor Properties

**Core Settings**

* `material_footstep_sound_map`: List of `MaterialFootstepSound` resources.
* `default_material_footstep_sound`: The fallback sound if no match is found.
* `target_character`: The `CharacterBody3D` whose movement is tracked.
* `accepted_meta_data_names`: Metadata keys to check (default: `["surface_type"]`).

**Auto Play Settings**

* `auto_play`: If true, footsteps play automatically. Disable this property if you want to play the footstep sound during animations. Once you have disabled this property, just connect to the `play` method in the `MaterialFootstepPlayer` node.
* `auto_play_delay`: Time (in seconds) between each footstep, only works when `auto_play` property is on.

**Debug Settings**

* `debug`: If true, debug logs print to console.

---

## Support

Star this repository... I guess.

---
