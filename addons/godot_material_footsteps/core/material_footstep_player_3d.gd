@icon("../assets/editor_icons/icon.png")
class_name MaterialFootstepPlayer3D
extends RayCast3D



@export_group("Core Settings")
@export var character: CharacterBody3D
@export var material_footstep_sound_map: Array[MaterialFootstep]
@export var default_material_footstep_sound: AudioStream
@export_group("Optional Overrides")
@export var audio_player: AudioStreamPlayer3D = null
@export_group("Advanced Settings")
@export var accepted_meta_data_names: PackedStringArray =["surface_type"]
@export var auto_play: bool = true
@export var auto_play_delay: float = 0.45
@export_group("Debug")
@export var debug: bool = true


var chain_of_responsibility = preload("../scripts/chain_of_responsibility.gd").new()
var count_up_timer = preload("../scripts/count_up_timer.gd").new()
var meta_data_material_detector = preload("../scripts/material_detectors/meta_data_material_detector.gd").new()
var grid_map_material_detector = preload("../scripts/material_detectors/grid_map_material_detector.gd").new()
@onready var null_validator = preload("../scripts/validators/null_validator.gd").new({"character": character, "material_footstep_sound_map": material_footstep_sound_map, "default_material_footstep_sound": default_material_footstep_sound})
@onready var composite_validator = preload("../scripts/validators/composite_validator.gd").new([null_validator])

var _all_possible_material_names: PackedStringArray
var _sound_map : Dictionary = {}

func _setup_sound_map() -> void:
	for entry in material_footstep_sound_map:
		_sound_map[entry.material_name] = entry.sounds

func _setup_chain() -> void:
	chain_of_responsibility.add_handler(grid_map_material_detector.detect)
	chain_of_responsibility.add_handler(meta_data_material_detector.detect)

func _ready() -> void:
	composite_validator.validate()
	_setup_sound_map()
	_setup_chain()
	if audio_player == null:
		audio_player = AudioStreamPlayer3D.new()
		add_child(audio_player)
	_update_all_possible_material_names()
	count_up_timer.start()

func _physics_process(delta: float) -> void:
	if not auto_play:
		return
	if count_up_timer.is_elapsed(auto_play_delay):
		play()
		count_up_timer.reset()
	count_up_timer.update(delta)

func _determine_material_name(collider: Object) -> Variant:
	if collider == null:
		return null
	return chain_of_responsibility.handle([get_collider(), get_collision_point()])

func _is_character_moving() -> bool:
	return character and character.is_on_floor() and character.velocity.length() > 0.1

func _update_all_possible_material_names() -> void:
	_all_possible_material_names = material_footstep_sound_map.map(func(entry): return entry.material_name)
	meta_data_material_detector.accepted_meta_data_names = accepted_meta_data_names
	meta_data_material_detector.all_possible_material_names = _all_possible_material_names
	grid_map_material_detector.all_possible_material_names = _all_possible_material_names

func play() -> void:
	if not is_colliding() or not _is_character_moving():
		_debug("[Godot Material Footsteps] No collider detected, not playing any sound or character not moving or character is just falling.")
		return
	var material_name = _determine_material_name(get_collider())
	if material_name:
		_play_sound_for_material(material_name)
		_debug("[Godot Material Footsteps] Hit surface: %s" % material_name)
	else:
		_debug("[Godot Material Footsteps] No material found, using Default")
		_play_sound_for_material("Default")


func _play_sound_for_material(material_name: String) -> void:
	var sounds = _sound_map.get(material_name, [])
	if sounds.is_empty():
		audio_player.stream = default_material_footstep_sound
		_debug("[Godot Material Footsteps] Playing default sound")
	else:
		audio_player.stream = sounds[randi_range(0, sounds.size() - 1)]
		_debug("[Godot Material Footsteps] Playing sound for: %s | Clip: %s" % [material_name, audio_player.stream.resource_path])
	audio_player.play()

func _debug(msg: String) -> void:
	if debug and OS.is_debug_build():
		print(msg)
