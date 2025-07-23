@icon("../assets/editor_icons/icon.png")
class_name MaterialFootstepPlayer3D
extends RayCast3D

# --- ENUMS ---
enum FootstepType { MOVEMENT, LANDING }
enum AutoPlayType {STATIC, DYNAMIC, DISABLED}
# --- EXPORTS ---

@export_group("Core Settings")
@export var character: CharacterBody3D
@export var material_footstep_sound_map: Array[MaterialFootstep]
@export var default_material_footstep_movement_sound: AudioStream
@export var default_material_footstep_landing_sound: AudioStream

@export_group("Optional Overrides")
@export var audio_player: AudioStreamPlayer3D = null

@export_group("Advanced Settings")
@export var accepted_meta_data_names: PackedStringArray = ["surface_type"]

@export_group("Auto Play Settings")
@export var auto_play_type: AutoPlayType = AutoPlayType.DYNAMIC
@export_subgroup("Dynamic Auto Play Settings")
@export var min_footstep_delay: float = 0.2
@export var max_footstep_delay: float = 0.6
@export var character_max_speed: float = 16.0
@export_subgroup("Static Auto Play Settings")
@export var auto_play_delay: float = 0.45

@export_group("Debug")
@export var debug: bool = true

# --- INTERNAL STATE ---

var chain_of_responsibility = preload("../scripts/chain_of_responsibility.gd").new()
var count_up_timer = preload("../scripts/count_up_timer.gd").new()
var meta_data_material_detector = preload("../scripts/material_detectors/meta_data_material_detector.gd").new()
var grid_map_material_detector = preload("../scripts/material_detectors/grid_map_material_detector.gd").new()
var landing_detector = preload("../scripts/landing_detector.gd").new()

@onready var null_validator = preload("../scripts/validators/null_validator.gd").new({
	"character": character,
	"material_footstep_sound_map": material_footstep_sound_map,
	"default_material_footstep_movement_sound": default_material_footstep_movement_sound,
	"default_material_footstep_landing_sound": default_material_footstep_landing_sound
})

@onready var composite_validator = preload("../scripts/validators/composite_validator.gd").new([null_validator])

var _all_possible_material_names: PackedStringArray
var _movement_sound_map: Dictionary = {}
var _landing_sound_map: Dictionary = {}

# --- INITIALIZATION ---

func _ready() -> void:
	composite_validator.validate()
	landing_detector.landed.connect(_on_player_landed)
	_initialize_sound_maps()
	_initialize_chain_of_responsibility()
	_update_material_detector_properties()
	_initialize_audio_player()
	count_up_timer.start()

func _initialize_sound_maps() -> void:
	for entry in material_footstep_sound_map:
		_movement_sound_map[entry.material_name] = entry.movement_sound
		_landing_sound_map[entry.material_name] = entry.landing_sound

func _initialize_chain_of_responsibility() -> void:
	chain_of_responsibility.add_handler(grid_map_material_detector.detect)
	chain_of_responsibility.add_handler(meta_data_material_detector.detect)

func _update_material_detector_properties() -> void:
	_all_possible_material_names = material_footstep_sound_map.map(
		func(entry): return entry.material_name
	)
	meta_data_material_detector.accepted_meta_data_names = accepted_meta_data_names
	meta_data_material_detector.all_possible_material_names = _all_possible_material_names
	grid_map_material_detector.all_possible_material_names = _all_possible_material_names

func _initialize_audio_player() -> void:
	if audio_player == null:
		audio_player = AudioStreamPlayer3D.new()
		add_child(audio_player)

# --- MAIN LOOP ---

func _physics_process(delta: float) -> void:
	landing_detector.update(character)
	var footstep_delay: float
	if auto_play_type == AutoPlayType.DYNAMIC:
		var current_speed = character.velocity.length()
		var speed_ratio = clamp(current_speed / character_max_speed, 0.0, 1.0)
		footstep_delay = lerp(max_footstep_delay, min_footstep_delay, speed_ratio)
	elif auto_play_type == AutoPlayType.STATIC:
		footstep_delay = auto_play_delay
	if count_up_timer.is_elapsed(footstep_delay) and not auto_play_type == AutoPlayType.DISABLED:
		play_footstep(FootstepType.MOVEMENT)
		count_up_timer.reset()

	count_up_timer.update(delta)

# --- FOOTSTEP PLAYBACK ---

func play_footstep(type: FootstepType) -> void:
	if not is_colliding():
		_log_debug("No collider detected. No sound will be played.")
		return

	if type == FootstepType.MOVEMENT and not _is_character_on_floor_and_moving():
		_log_debug("Character not moving or not on floor. Movement sound skipped.")
		return

	var material_name = _determine_material_name(get_collider())
	if material_name != null:
		_play_sound_for_material(material_name, type)
		_log_debug("Hit surface: %s" % material_name)
	else:
		_log_debug("No material found underfoot, playing default sound.")
		_play_sound_for_material("Default", type)

func _play_sound_for_material(material_name: String, type: FootstepType) -> void:
	var sound_to_play: AudioStream = null

	match type:
		FootstepType.MOVEMENT:
			sound_to_play = _movement_sound_map.get(material_name)
		FootstepType.LANDING:
			sound_to_play = _landing_sound_map.get(material_name)

	if sound_to_play == null:
		if type == FootstepType.MOVEMENT:
			audio_player.stream = default_material_footstep_movement_sound
		elif type == FootstepType.LANDING:
			audio_player.stream = default_material_footstep_landing_sound
		_log_debug("Playing default footstep sound.")
	else:
		audio_player.stream = sound_to_play
		_log_debug("Playing sound for %s: %s" % [material_name, audio_player.stream.resource_path])

	audio_player.play()

# --- HELPERS ---

func _determine_material_name(collider: Object) -> Variant:
	if collider == null:
		return null
	return chain_of_responsibility.handle([collider, get_collision_point()])

func _is_character_on_floor_and_moving() -> bool:
	return character and character.is_on_floor() and character.velocity.length() > 0.1

func _log_debug(message: String) -> void:
	if debug and OS.is_debug_build():
		print("[Godot Material Footsteps] " + message)

# --- SIGNAL HANDLERS ---

func _on_player_landed(fall_speed: float) -> void:
	_log_debug("Player landed.")
	play_footstep(FootstepType.LANDING)
	count_up_timer.reset()
