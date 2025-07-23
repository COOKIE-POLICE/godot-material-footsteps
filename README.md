
---

## Godot Material Footsteps


<p align="center">
  <img src="addons/godot_material_footsteps/assets/editor_icons/icon.png"alt="Godot Material Footsteps Icon", width="128"height="128"/>
</p>

A Godot 3D addon for automatically playing footstep sounds based on the material a character walks on. This addon supports mainly a metadata-based solution, but it also supports GridMap.

[Check it out on Godot Asset Library!](https://godotengine.org/asset-library/asset/4122)

---

## Table of Contents

- [Godot Material Footsteps](#godot-material-footsteps)
- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Support](#support)

---

## Usage

[![Video Tutorial](https://img.youtube.com/vi/zFgYhZyGRw0/hqdefault.jpg)](https://youtu.be/zFgYhZyGRw0)
Keep in mind the video above is a little outdated.

1. In your player scene:
   * Add a `MaterialFootstepPlayer3D` node pointing under your character.

2. In the Inspector for the `MaterialFootstepPlayer3D`:
   * Set `target_character` to your player.
   * Fill in `material_footstep_sound_map` with `MaterialFootstep` resources mapping material names to sound lists.
   * Set a `default_material_footstep_sound`.

3. In your level scene:
   * Select any floor (e.g. `StaticBody3D` or any ancestor or descendant of that `StaticBody3D`).
   * In the Inspector, under **Metadata**, add a new key-value pair:
	 * Key: `surface_type`
	 * Value: matching the names in your `material_footstep_sound_map`.

4. If you are using the GridMap node. It is the same process. However, since the GridMap does not support any type of metadata, you instead have to match each tile's name to whatever you put in your `material_footstep_sound_map`.

5. If you need multiple `AudioStream` for a material you should use the Godot `AudioStreamPlaylist` or `AudioStreamRandomizer` resources. Also for `AudioStreamRandomizer` turn off loop. If I see a issue open about audio continue playing on a surface even while staying still and you use `AudioStreamRandimizer` with loop on, I am going to crash out.
---

## Support

Star this repository, contribute and open issues.

---
