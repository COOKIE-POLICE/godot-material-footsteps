@icon("res://addons/godot_material_footsteps/assets/editor_icons/icon.png")
class_name MaterialFootstepPlayer3D
extends RayCast3D

const ChainOfResponsibility = preload("res://addons/godot_material_footsteps/core/chain_of_responsibility.gd")
const CountUpTimer = preload("res://addons/godot_material_footsteps/core/count_up_timer.gd")

@export_category("Core Settings")
@export var material_footstep_sound_map: Array[MaterialFootstepSound]
@export var default_material_footstep_sound: AudioStream
@export var target_character: CharacterBody3D
@export var accepted_meta_data_names: Array[String] = ["surface_type"]


@export_category("Auto Play Settings")
@export var auto_play: bool = true
@export var auto_play_delay: float = 0.45

@export_category("Debug Settings")
@export var debug: bool = true

@onready var _audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

var _all_possible_material_names: Array
var _auto_play_timer: CountUpTimer = CountUpTimer.new()
var chain = ChainOfResponsibility.new()
var _sound_map : Dictionary = {}

func _setup_sound_map() -> void:
	for entry in material_footstep_sound_map:
		_sound_map[entry.material_name] = entry.sounds

func _setup_chain() -> void:
	chain.add_handler(_determine_by_meta)
	chain.add_handler(_determine_by_meta_of_descendants)
	chain.add_handler(_determine_by_meta_of_ancestors)

func _ready() -> void:
	print(_audio_player)
	_setup_sound_map()
	_setup_chain()
	add_child(_audio_player)
	_update_all_possible_material_names()

func _physics_process(delta: float) -> void:
	if not auto_play:
		return
	_auto_play_timer.update(delta)
	if _auto_play_timer.is_elapsed(auto_play_delay):
		play()
		_auto_play_timer.reset()

func _is_character_moving() -> bool:
	return target_character and target_character.is_on_floor() and target_character.velocity.length() > 0.1

func _update_all_possible_material_names() -> void:
	_all_possible_material_names = material_footstep_sound_map.map(func(entry): return entry.material_name)
	print(_all_possible_material_names)
func _determine_material_name(collider: Object) -> Variant:
	if collider == null:
		return null
	return chain.handle(collider)

func _determine_by_meta(collider: Object) -> Variant:
	for meta_name in accepted_meta_data_names:
		if collider.has_meta(meta_name):
			var material_name = collider.get_meta(meta_name)
			if material_name in _all_possible_material_names:
				return material_name
	return null

func _determine_by_meta_of_descendants(collider: Object) -> Variant:
	for child in collider.get_children():
		var material_name = _determine_by_meta(child)
		if material_name == null:
			var descendant_result = _determine_by_meta_of_descendants(child)
			if descendant_result != null:
				return descendant_result
		else:
			return material_name
	return null

func _determine_by_meta_of_ancestors(collider: Object) -> Variant:
	var current = collider.get_parent()
	while current:
		var material_name = _determine_by_meta(current)
		if material_name == null:
			current = current.get_parent()
		else:
			return material_name
	return null
		


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
		_audio_player.stream = default_material_footstep_sound
		_debug("[Godot Material Footsteps] Playing default sound")
	else:
		_audio_player.stream = sounds[randi_range(0, sounds.size() - 1)]
		_debug("[Godot Material Footsteps] Playing sound for: %s | Clip: %s" % [material_name, _audio_player.stream.resource_path])
	_audio_player.play()

func _debug(msg: String) -> void:
	if debug and OS.is_debug_build():
		print(msg)
