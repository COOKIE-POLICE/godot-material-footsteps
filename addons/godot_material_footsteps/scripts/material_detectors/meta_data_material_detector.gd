extends "./material_detector.gd"

var accepted_meta_data_names: PackedStringArray = ["surface_type"]
var all_possible_material_names: PackedStringArray = []
var caching: bool = true

var _material_cache: Dictionary = {}
var _valid_materials_set: Dictionary = {}

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
	_material_cache.clear()

func _get_cached_material(instance_id: int) -> Variant:
	if not caching:
		return null
	if not _material_cache.has(instance_id):
		return null
	
	var obj = instance_from_id(instance_id)
	if is_instance_valid(obj):
		return _material_cache[instance_id]
	
	_material_cache.erase(instance_id)
	return null

func _cache_material(instance_id: int, material: Variant) -> void:
	if not caching:
		return
	_material_cache[instance_id] = material if material else ""

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
			if _valid_materials_set.has(material_name):
				return material_name
	
	return null

func _detect_in_descendants(parent: Node) -> Variant:
	if not parent:
		return null
	
	var children = parent.find_children("*", "", true, false)
	for child in children:
		var material = _detect_material_on_object(child)
		if material:
			return material
	
	return null

func _detect_in_ancestors(node: Node) -> Variant:
	var current = node.get_parent() if node else null

	while current:
		var material = _detect_material_on_object(current)
		if material:
			return material
		current = current.get_parent()

	return null

func _ensure_materials_set_initialized() -> void:
	if _valid_materials_set.is_empty() and not all_possible_material_names.is_empty():
		for material_name in all_possible_material_names:
			_valid_materials_set[material_name] = true
