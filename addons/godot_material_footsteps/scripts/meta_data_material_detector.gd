extends RefCounted
class_name MetaDataMaterialDetector

var accepted_meta_data_names: PackedStringArray = ["surface_type"]
var all_possible_material_names : PackedStringArray = []

func detect(collider: Object, collision_point: Vector3) -> Variant:
	var result = _detect_material(collider)
	if result != null:
		return result

	result = _detect_in_descendants(collider)
	if result != null:
		return result
	return _detect_in_ancestors(collider)

func _detect_material(collider: Object) -> Variant:
	if collider == null:
		return null
	for meta_name in accepted_meta_data_names:
		if collider.has_meta(meta_name):
			var material_name = collider.get_meta(meta_name)
			if material_name in all_possible_material_names:
				return material_name
	return null

func _detect_in_descendants(collider: Object) -> Variant:
	if collider == null:
		return null
	for child in collider.get_children():
		var name = _detect_material(child)
		if name != null:
			return name
		name = _detect_in_descendants(child)
		if name != null:
			return name
	return null

func _detect_in_ancestors(collider: Object) -> Variant:
	var current = collider
	while current:
		var name = _detect_material(current)
		if name != null:
			return name
		current = current.get_parent()
	return null
