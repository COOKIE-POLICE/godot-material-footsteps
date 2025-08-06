## Godot Material Footsteps

<p align="center">
  <img src="addons/godot_material_footsteps/assets/editor_icons/icon.png" alt="Godot Material Footsteps Icon" width="128" height="128"/>
</p>

A Godot 3D addon for automatically playing footstep sounds based on the material a character walks on. This addon supports mainly a metadata-based solution, but it also supports GridMap and HTerrain Classic4 shader.

[Check it out on Godot Asset Library!](https://godotengine.org/asset-library/asset/4122)

---

## Table of Contents

- [Godot Material Footsteps](#godot-material-footsteps)
- [Table of Contents](#table-of-contents)
- [Tutorial](#tutorial)
  - [Step 1: Add the Footstep Player](#step-1-add-the-footstep-player)
  - [Step 2: Configure the Footstep Player](#step-2-configure-the-footstep-player)
  - [Step 3: Set Up Your Surfaces](#step-3-set-up-your-surfaces)
	- [Method A: Using Metadata (Recommended)](#method-a-using-metadata-recommended)
	- [Method B: Using GridMap](#method-b-using-gridmap)
	- [Method C: Using HTerrain Classic4 Shader](#method-c-using-hterrain-classic4-shader)
  - [Step 4: Handle Multiple Sounds](#step-4-handle-multiple-sounds)
- [Support](#support)

---

## Tutorial

[![Video Tutorial](https://img.youtube.com/vi/zFgYhZyGRw0/hqdefault.jpg)](https://youtu.be/zFgYhZyGRw0)
*Note: The video above is a little outdated.*

### Step 1: Add the Footstep Player

In your player scene, add a `MaterialFootstepPlayer3D` node under your character.

### Step 2: Configure the Footstep Player

In the Inspector for the `MaterialFootstepPlayer3D`:

1. **Set Target Character**: Point `target_character` to your player node.

2. **Create Material Sound Map**: Fill in `material_footstep_sound_map` with `MaterialFootstep` resources that map material names to sound lists.

3. **Set Default Sound**: Configure `default_material_footstep_sound` for fallback audio.

### Step 3: Set Up Your Surfaces

Choose the method that matches your level setup:

#### Method A: Using Metadata (Recommended)

1. In your level scene, select any floor object (e.g., `StaticBody3D` or any of its ancestor/descendant nodes).

2. In the Inspector, go to the **Metadata** section.

3. Add a new key-value pair:
   - **Key**: `surface_type`
   - **Value**: A name that matches one in your `material_footstep_sound_map`

#### Method B: Using GridMap

1. Since GridMap doesn't support metadata, match each tile's **name** to the names in your `material_footstep_sound_map`.

2. The addon will automatically detect the tile name when the character walks on it.

#### Method C: Using HTerrain Classic4 Shader

1. For HTerrain Classic4 shader support, specify the texture index in your `material_footstep_sound_map` names.

2. The addon will detect which terrain texture the character is walking on based on the shader's texture blending.

### Step 4: Handle Multiple Sounds

If you need multiple audio streams for one material:

- Use Godot's `AudioStreamPlaylist` or `AudioStreamRandomizer` resources.
- **Important**: For `AudioStreamRandomizer`, turn off the loop setting to prevent continuous audio playback when standing still.

---

## Support

Star this repository, contribute and open issues.
