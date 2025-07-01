@icon("res://addons/godot_material_footsteps/assets/editor_icons/icon.png")
extends RayCast3D
class_name MaterialFootstepPlayer

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

var _all_possible_material_names: Array[String]
var _audio_player: AudioStreamPlayer3D
var _auto_play_timer: float = 0.0

func _ready() -> void:
	_audio_player = AudioStreamPlayer3D.new()
	add_child(_audio_player)
	_all_possible_material_names = _calculate_all_possible_material_names()

func _physics_process(delta: float) -> void:
	if not auto_play:
		return
	_auto_play_timer -= delta
	if _auto_play_timer <= 0.0:
		play()
		_auto_play_timer = auto_play_delay

func _is_character_falling() -> bool:
	return target_character and not target_character.is_on_floor() and target_character.velocity.y < 0.0

func _is_character_moving() -> bool:
	return target_character and target_character.velocity.length() > 0.1

func _refresh_all_possible_material_names() -> void:
	_all_possible_material_names = _calculate_all_possible_material_names()

func _determine_material_name(collider: Object) -> Variant:
	if collider == null:
		return null
	var chain = ChainOfResponsibility.new()
	chain.add_handler(func(collider): return _determine_by_meta(collider))
	chain.add_handler(func(collider): return _determine_by_meta_of_descendants(collider))
	chain.add_handler(func(collider): return _determine_by_meta_of_ancestors(collider))
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
			_determine_by_meta_of_descendants(child)
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
	_refresh_all_possible_material_names()
	if not is_colliding() or _is_character_falling() or not _is_character_moving():
		_debug("[Godot Material Footsteps] No collider detected, not playing any sound or character not moving or character is just falling.")
		return
	var material_name = _determine_material_name(get_collider())
	if material_name:
		_play_sound_for_material(material_name)
		_debug("[Godot Material Footsteps] Hit surface: %s" % material_name)
	else:
		_debug("[Godot Material Footsteps] No material found, using Default")
		_play_sound_for_material("Default")

func _calculate_all_possible_material_names() -> Array[String]:
	var names: Array[String]
	for entry in material_footstep_sound_map:
		names.append(entry.material_name)
	return names

func _play_sound_for_material(material_name: String) -> void:
	var sounds: Array[AudioStream]
	for entry in material_footstep_sound_map:
		if entry.material_name == material_name:
			sounds = entry.sounds
			break
	if sounds.is_empty():
		_audio_player.stream = default_material_footstep_sound
		_debug("[Godot Material Footsteps] Playing default sound")
	else:
		_audio_player.stream = sounds[randi() % sounds.size()]
		_debug("[Godot Material Footsteps] Playing sound for: %s | Clip: %s" % [material_name, _audio_player.stream.resource_path])
	_audio_player.play()

func _debug(msg: String) -> void:
	if debug:
		print(msg)
