extends "./material_detector.gd"

# --- CONFIGURATION ---
var all_possible_material_names: PackedStringArray = []

# --- INTERNAL STATE ---
var valid_materials_set: Dictionary = {}

# --- PUBLIC API ---
func detect(raycast: RayCast3D) -> Variant:
	var collider = raycast.get_collider()
	if not collider:
		return null
	
	var collision_point = raycast.get_collision_point()
	var is_hterrain = false
	if collider.get_script():
		var script_path = collider.get_script().get_path()
		is_hterrain = script_path.get_file() == "hterrain.gd"
	
	if is_hterrain:
		var material = _detect_hterrain_material(collider, collision_point)
		if material:
			return material
	
	return null

# --- PRIVATE METHODS ---
func _detect_hterrain_material(terrain: Object, world_pos: Vector3) -> Variant:
	_ensure_materials_set_initialized()
	
	var terrain_data = terrain.get_data()
	if not terrain_data:
		return null
	var local_pos = terrain.to_local(world_pos)
	var resolution = terrain_data.get_resolution()
	var cell_x = int(clamp(local_pos.x, 0, resolution - 1))
	var cell_z = int(clamp(local_pos.z, 0, resolution - 1))

	var splatmap_texture = _get_splatmap_texture(terrain_data)
	if not splatmap_texture:
		return null
	
	var image = splatmap_texture.get_image()
	if not image:
		return null
	var img_x = int(clamp(cell_x * image.get_width() / resolution, 0, image.get_width() - 1))
	var img_z = int(clamp(cell_z * image.get_height() / resolution, 0, image.get_height() - 1))
	var pixel = image.get_pixel(img_x, img_z)
	var dominant_texture_index = _get_dominant_channel_index(pixel)
	return _get_material_name_from_index(dominant_texture_index)

func _get_splatmap_texture(terrain_data: Object) -> Texture2D:
	if terrain_data.has_method("get_texture"):
		for map_type in [2, 3, 4]:
			var texture = terrain_data.get_texture(map_type)
			if texture:
				return texture

	if terrain_data.has_method("get_splatmap"):
		return terrain_data.get_splatmap(0)
	
	return null

func _get_dominant_channel_index(pixel: Color) -> int:
	var channels = [pixel.r, pixel.g, pixel.b, pixel.a]
	var max_weight = 0.0
	var dominant_index = -1
	
	for i in range(4):
		if channels[i] > max_weight:
			max_weight = channels[i]
			dominant_index = i
	
	return dominant_index

func _get_material_name_from_index(texture_index: int) -> Variant:
	if texture_index < 0 or texture_index >= all_possible_material_names.size():
		return null
	
	var material_name = all_possible_material_names[texture_index]
	if valid_materials_set.has(material_name):
		return material_name
	
	return null

func _ensure_materials_set_initialized() -> void:
	if valid_materials_set.is_empty() and not all_possible_material_names.is_empty():
		for material_name in all_possible_material_names:
			valid_materials_set[material_name] = true
