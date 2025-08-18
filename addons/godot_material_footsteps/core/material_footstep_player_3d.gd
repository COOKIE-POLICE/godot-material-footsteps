@tool
@icon("../assets/editor_icons/icon.png")
class_name MaterialFootstepPlayer3D
extends RayCast3D

# --- ENUMS ---
enum FootstepType { MOVEMENT, LANDING }
enum AutoPlayType { STATIC, DYNAMIC, DISABLED }

# --- EXPORTS ---
@export_group("Core Settings")
@export var character: CharacterBody3D
@export var material_footstep_sound_map: Array[MaterialFootstep]

@export_group("Override Settings")
@export var audio_player: AudioStreamPlayer3D

@export_group("Feature Settings")
@export var grid_map_material_detection: bool = true
@export var meta_data_material_detection: bool = true
@export var h_terrain_material_detection: bool = true

@export_group("Advanced Settings")
@export var accepted_meta_data_names: PackedStringArray = ["surface_type"]
@export_group("Default Sounds Settings")
@export var default_material_footstep_movement_sound: AudioStream
@export var default_material_footstep_landing_sound: AudioStream

@export_group("Auto Play Settings")
@export var auto_play_type: AutoPlayType = AutoPlayType.DYNAMIC
@export_subgroup("Dynamic Auto Play Settings")
@export var min_footstep_delay: float = 0.2
@export var max_footstep_delay: float = 0.6
@export var character_max_speed: float = 16.0
@export var min_movement_velocity: float = 0.1
@export_subgroup("Static Auto Play Settings")
@export var auto_play_delay: float = 0.45

@export_group("Debug Settings")
@export var debug: bool = true

# --- CONSTANTS ---
const SCRIPTS_PATH = "../scripts/"

# --- INTERNAL STATE ---
var chain_of_responsibility: RefCounted
var count_up_timer: RefCounted
var meta_data_material_detector: RefCounted
var grid_map_material_detector: RefCounted
var h_terrain_material_detector: RefCounted
var landing_detector: RefCounted

var movement_sound_map: Dictionary
var landing_sound_map: Dictionary
var all_possible_material_names: PackedStringArray
var cached_footstep_delay: float
var last_speed_ratio: float = -1.0

# --- INITIALIZATION ---
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_create_components()
	_setup_sound_maps()
	_configure_material_detectors()
	_setup_audio_player()
	_connect_signals()
	count_up_timer.start()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not character:
		warnings.append("%s requires a character" % get_script().get_global_name())
	if not material_footstep_sound_map:
		warnings.append("%s requires a material footstep sound map" % get_script().get_global_name())
	return warnings

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE:
		update_configuration_warnings()
	

func _create_components() -> void:
	chain_of_responsibility = preload(SCRIPTS_PATH + "chain_of_responsibility.gd").new()
	count_up_timer = preload(SCRIPTS_PATH + "count_up_timer.gd").new()
	meta_data_material_detector = preload(SCRIPTS_PATH + "material_detectors/meta_data_material_detector.gd").new()
	grid_map_material_detector = preload(SCRIPTS_PATH + "material_detectors/grid_map_material_detector.gd").new()
	h_terrain_material_detector = preload(SCRIPTS_PATH + "material_detectors/h_terrain_material_detector.gd").new()
	landing_detector = preload(SCRIPTS_PATH + "landing_detector.gd").new()

func _setup_sound_maps() -> void:
	movement_sound_map.clear()
	landing_sound_map.clear()
	all_possible_material_names.clear()
	
	for entry in material_footstep_sound_map:
		var material_name = entry.material_name
		movement_sound_map[material_name] = entry.movement_sound
		landing_sound_map[material_name] = entry.landing_sound
		all_possible_material_names.append(material_name)

func _configure_material_detectors() -> void:
	if grid_map_material_detection:
		chain_of_responsibility.add_handler(grid_map_material_detector.detect)
	if meta_data_material_detection:
		chain_of_responsibility.add_handler(meta_data_material_detector.detect)
	if h_terrain_material_detection:
		chain_of_responsibility.add_handler(h_terrain_material_detector.detect)
	
	var shared_properties = {
		"accepted_meta_data_names": accepted_meta_data_names,
		"all_possible_material_names": all_possible_material_names
	}
	for detector in [meta_data_material_detector, grid_map_material_detector, h_terrain_material_detector]:
		for property_name in shared_properties:
			detector.set(property_name, shared_properties[property_name])

func _setup_audio_player() -> void:
	if not audio_player:
		audio_player = AudioStreamPlayer3D.new()
		add_child(audio_player)

func _connect_signals() -> void:
	landing_detector.landed.connect(_on_player_landed)

# --- MAIN LOOP ---
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	landing_detector.update(character)
	
	if auto_play_type == AutoPlayType.DISABLED:
		count_up_timer.update(delta)
		return
	
	var footstep_delay = _get_current_footstep_delay()
	if count_up_timer.is_elapsed(footstep_delay):
		_try_play_movement_footstep()
		count_up_timer.reset()
	
	count_up_timer.update(delta)

func _get_current_footstep_delay() -> float:
	if auto_play_type == AutoPlayType.STATIC:
		return auto_play_delay
	
	var speed_ratio = _calculate_speed_ratio()
	if speed_ratio != last_speed_ratio:
		cached_footstep_delay = lerpf(max_footstep_delay, min_footstep_delay, speed_ratio)
		last_speed_ratio = speed_ratio
	
	return cached_footstep_delay

func _calculate_speed_ratio() -> float:
	var current_speed = character.velocity.length()
	return clampf(current_speed / character_max_speed, 0.0, 1.0)

func _try_play_movement_footstep() -> void:
	if _should_play_movement_sound():
		play_footstep(FootstepType.MOVEMENT)

func _should_play_movement_sound() -> bool:
	return (is_colliding() and 
			character and 
			character.is_on_floor() and 
			character.velocity.length() > min_movement_velocity)

# --- FOOTSTEP PLAYBACK ---
func play_footstep(type: FootstepType) -> void:
	if not is_colliding():
		_debug_log("No collider detected. No sound will be played.")
		return
	
	if type == FootstepType.MOVEMENT and not _should_play_movement_sound():
		_debug_log("Character not moving or not on floor. Movement sound skipped.")
		return
	
	var material_name = _detect_surface_material()
	var sound_stream = _get_sound_for_material(material_name, type)
	if sound_stream:
		audio_player.stream = sound_stream
		audio_player.play()
		if material_name:
			_debug_log("Playing sound for %s: %s" % [material_name, audio_player.stream.resource_path])
		else:
			_debug_log("Playing default footstep sound: %s" % [audio_player.stream.resource_path])
	else:
		_debug_log("No sound availible, playing no sound.")

func _detect_surface_material() -> String:
	var collider = get_collider()
	if not collider:
		return ""
	
	var material_name = chain_of_responsibility.handle([self])
	return material_name if material_name else ""

func _get_sound_for_material(material_name: String, type: FootstepType) -> AudioStream:
	var sound_map = landing_sound_map if type == FootstepType.LANDING else movement_sound_map
	var default_sound = default_material_footstep_landing_sound if type == FootstepType.LANDING else default_material_footstep_movement_sound
	
	return sound_map.get(material_name, default_sound)

# --- HELPERS ---
func _debug_log(message: String) -> void:
	if debug and OS.is_debug_build():
		print("[Godot Material Footsteps] " + message)

# --- SIGNAL HANDLERS ---
func _on_player_landed(fall_speed: float) -> void:
	_debug_log("Player landed.")
	play_footstep(FootstepType.LANDING)
	count_up_timer.reset()
