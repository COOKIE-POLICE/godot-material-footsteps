<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<br />
<div align="center">
  <a href="https://github.com/COOKIE-POLICE/godot-material-footsteps">
    <img src="addons/godot_material_footsteps/assets/editor_icons/icon.png" alt="Logo" width="128" height="128">
  </a>

  <h3 align="center">Godot Material Footsteps</h3>

  <p align="center">
    Automatically play footstep sounds based on surface materials in Godot 4
    <br />
    <a href="https://github.com/COOKIE-POLICE/godot-material-footsteps"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://youtu.be/zFgYhZyGRw0">View Demo</a>
    ·
    <a href="https://github.com/COOKIE-POLICE/godot-material-footsteps/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/COOKIE-POLICE/godot-material-footsteps/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#features">Features</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#step-1-add-the-footstep-player">Step 1: Add the Footstep Player</a></li>
        <li><a href="#step-2-configure-the-materialfootstepplayer3d">Step 2: Configure the Footstep Player</a></li>
        <li><a href="#step-3-set-up-your-surfaces">Step 3: Set Up Your Surfaces</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## About The Project

[![Video Tutorial](https://img.youtube.com/vi/zFgYhZyGRw0/hqdefault.jpg)](https://youtu.be/zFgYhZyGRw0)

Godot Material Footsteps is an addon for Godot 4 that plays footstep sounds based on the surface your character is walking on. Instead of manually scripting sounds for each type of surface, you can directly configure the surfaces in the editor inspector. It works with different setups, including metadata on meshes, GridMap tiles, and HTerrain Classic4 shaders.

This addon is available on the [Godot Asset Library](https://godotengine.org/asset-library/asset/4122).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Godot][Godot-badge]][Godot-url]
* [![GDScript][GDScript-badge]][GDScript-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Features

- **Multiple Detection Methods**: Metadata, GridMap tiles, and HTerrain shader support
- **Easy Configuration**: Map sounds to materials directly in the inspector
- **Fallback System**: Default sounds when no material match is found
- **Efficient**: Very performant

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Installation

1. Download the addon from the [Godot Asset Library](https://godotengine.org/asset-library/asset/4122) or clone this repository
   ```sh
   git clone https://github.com/COOKIE-POLICE/godot-material-footsteps.git
   ```

2. Copy the `addons/godot_material_footsteps` folder into your project's `addons` directory

3. Enable the plugin in Project Settings:
   - Go to **Project** → **Project Settings** → **Plugins**
   - Find "Godot Material Footsteps" and check the Enable box

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

### Step 1: Add the Footstep Player

In your player scene, add a `MaterialFootstepPlayer3D` node as a child of your character node.

```
CharacterBody3D (Your Player)
└── MaterialFootstepPlayer3D
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Step 2: Configure the MaterialFootstepPlayer3D

In the Inspector for the `MaterialFootstepPlayer3D`, you'll see three main properties to configure:

#### 2.1 Set Target Character

Set the `target_character` property to your player node (usually the parent node).

```
Inspector → MaterialFootstepPlayer3D
├── target_character: CharacterBody3D
```

#### 2.2 Create Material Sound Map

This is where you define which sounds play on which surfaces.

```
Inspector → MaterialFootstepPlayer3D
└── material_footstep_sound_map: Array[MaterialFootstep]
    ├── [0] MaterialFootstep
    │   ├── material_name: "wood"
    │   └── sounds: Array[AudioStreamPlaylist]
    │       ├── wood_step_01.wav
    │       ├── wood_step_02.wav
    │       └── wood_step_03.wav
    ├── [1] MaterialFootstep
    │   ├── material_name: "stone"
    │   └── sounds: Array[AudioStreamRandomizer]
    │       ├── stone_step_01.wav
    │       └── stone_step_02.wav
    └── [2] MaterialFootstep
        ├── material_name: "grass"
        └── sounds: Array[AudioStream]
            └── grass_step_01.wav
```

#### 2.3 Set Default Sound

Configure `default_material_footstep_sound` as a fallback.

```
Inspector → MaterialFootstepPlayer3D
└── default_material_footstep_sound: MaterialFootstep
    ├── material_name: "default"
    └── sounds: Array[AudioStream]
        └── generic_step.wav
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Step 3: Set Up Your Surfaces

Now that the player is configured, you need to tell surfaces what material they are. Choose the method that matches your level design:

#### Method A: Using Metadata (Recommended)

**Best for:** StaticBody3D meshes

The option to add metadata is at the very bottom of the in-editor inspector.



**Example Scene Structure:**
```
Level
├── WoodenFloor (StaticBody3D)
│   ├── CollisionShape3D
│   └── MeshInstance3D
│       └── Metadata:
│           surface_type: "wood"
├── StoneWall (StaticBody3D)
│   ├── CollisionShape3D
│   └── MeshInstance3D
│       └── Metadata:
│           surface_type: "stone"
└── GrassField (StaticBody3D)
    ├── CollisionShape3D
    └── MeshInstance3D
        └── Metadata:
            surface_type: "grass"
```


#### Method B: Using GridMap

**Best for:** Tile-based levels, dungeon crawlers, grid-based games

For GridMap-based levels, the tile's **name** in the MeshLibrary is automatically detected.

```
MeshLibrary
├── Item 0: "stone"      ← Matches "stone" in sound map
├── Item 1: "wood"      ← Matches "wood" in sound map
├── Item 2: "grass"       ← Matches "grass" in sound map
```

#### Method C: Using HTerrain Classic4 Shader

**Best for:** HTerrain-based levels

**Example Configuration:**
```
material_footstep_sound_map:
├── [0] MaterialFootstep
│   ├── material_name: "0"  ← HTerrain texture layer 0 (grass)
│   └── sounds: [grass_01.wav, grass_02.wav]
├── [1] MaterialFootstep
│   ├── material_name: "1"  ← HTerrain texture layer 1 (dirt)
│   └── sounds: [dirt_01.wav, dirt_02.wav]
├── [2] MaterialFootstep
│   ├── material_name: "2"  ← HTerrain texture layer 2 (rock)
│   └── sounds: [rock_01.wav, rock_02.wav]
└── [3] MaterialFootstep
    ├── material_name: "3"  ← HTerrain texture layer 3 (sand)
    └── sounds: [sand_01.wav, sand_02.wav]
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

- [x] Metadata-based surface detection
- [x] GridMap support
- [x] HTerrain Classic4 shader support
- [ ] Support for Terrain3D
- [ ] Automatic volume adjustment based on movement speed

See the [open issues](https://github.com/COOKIE-POLICE/godot-material-footsteps/issues) for a full list of proposed features and known issues.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Top contributors:

<a href="https://github.com/COOKIE-POLICE/godot-material-footsteps/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=COOKIE-POLICE/godot-material-footsteps" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

* [Choose an Open Source License](https://choosealicense.com)
* [Godot Engine](https://godotengine.org)
* [HTerrain Plugin](https://github.com/Zylann/godot_heightmap_plugin)
* [Best README Template](https://github.com/othneildrew/Best-README-Template)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/COOKIE-POLICE/godot-material-footsteps.svg?style=for-the-badge
[contributors-url]: https://github.com/COOKIE-POLICE/godot-material-footsteps/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/COOKIE-POLICE/godot-material-footsteps.svg?style=for-the-badge
[forks-url]: https://github.com/COOKIE-POLICE/godot-material-footsteps/network/members
[stars-shield]: https://img.shields.io/github/stars/COOKIE-POLICE/godot-material-footsteps.svg?style=for-the-badge
[stars-url]: https://github.com/COOKIE-POLICE/godot-material-footsteps/stargazers
[issues-shield]: https://img.shields.io/github/issues/COOKIE-POLICE/godot-material-footsteps.svg?style=for-the-badge
[issues-url]: https://github.com/COOKIE-POLICE/godot-material-footsteps/issues
[license-shield]: https://img.shields.io/github/license/COOKIE-POLICE/godot-material-footsteps.svg?style=for-the-badge
[license-url]: https://github.com/COOKIE-POLICE/godot-material-footsteps/blob/master/LICENSE.txt
[Godot-badge]: https://img.shields.io/badge/Godot-4.x-478CBF?style=for-the-badge&logo=godotengine&logoColor=white
[Godot-url]: https://godotengine.org/
[GDScript-badge]: https://img.shields.io/badge/GDScript-355570?style=for-the-badge&logo=godotengine&logoColor=white
[GDScript-url]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/