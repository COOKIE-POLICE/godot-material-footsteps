extends "./material_detector.gd"

# --- CONFIGURATION ---
var accepted_meta_data_names: PackedStringArray = ["surface_type"]
var all_possible_material_names: PackedStringArray = []
var caching: bool = true
# --- INTERNAL STATE ---
var material_cache: Dictionary = {}
var valid_materials_set: Dictionary = {}

# --- PUBLIC API ---
func detect(raycast: RayCast3D) -> Variant:
	var collider = raycast.get_collider()
	if not collider:
		return null
	
	var instance_id = collider.get_instance_id()
	var cached_result = _get_cached_material(instance_id)
	if cached_result != null:
		return cached_result if cached_result != "" else null
	
	var detected_material = _detect_material_hierarchy(collider)
	_cache_material(instance_id, detected_material)
	
	return detected_material

func clear_cache() -> void:
	material_cache.clear()

# --- PRIVATE METHODS ---
func _get_cached_material(instance_id: int) -> Variant:
	if not caching: 
		return
	if not material_cache.has(instance_id):
		return null
	
	var obj = instance_from_id(instance_id)
	if is_instance_valid(obj):
		return material_cache[instance_id]
	
	material_cache.erase(instance_id)
	return null

func _cache_material(instance_id: int, material: Variant) -> void:
	if not caching: 
		return
	material_cache[instance_id] = material if material else ""

func _detect_material_hierarchy(collider: Object) -> Variant:
	var material = _detect_material_on_object(collider)
	if material:
		return material
	
	material = _detect_in_descendants(collider)
	if material:
		return material
	
	return _detect_in_ancestors(collider)

func _detect_material_on_object(obj: Object) -> Variant:
	if not obj:
		return null
	
	_ensure_materials_set_initialized()
	
	for meta_name in accepted_meta_data_names:
		if obj.has_meta(meta_name):
			var material_name = obj.get_meta(meta_name)
			if valid_materials_set.has(material_name):
				return material_name
	
	return null

func _detect_in_descendants(parent: Object) -> Variant:
	if not parent:
		return null
	
	var stack: Array[Object] = [parent]
	var visited: Dictionary = {parent.get_instance_id(): true}
	
	while not stack.is_empty():
		var current = stack.pop_back()
		
		for child in current.get_children():
			var child_id = child.get_instance_id()
			if visited.has(child_id):
				continue
			
			visited[child_id] = true
			
			var material = _detect_material_on_object(child)
			if material:
				return material
			
			stack.push_back(child)
	
	return null

func _detect_in_ancestors(obj: Object) -> Variant:
	var current = obj.get_parent() if obj else null
	
	while current:
		var material = _detect_material_on_object(current)
		if material:
			return material
		current = current.get_parent()
	
	return null

func _ensure_materials_set_initialized() -> void:
	if valid_materials_set.is_empty() and not all_possible_material_names.is_empty():
		for material_name in all_possible_material_names:
			valid_materials_set[material_name] = true
