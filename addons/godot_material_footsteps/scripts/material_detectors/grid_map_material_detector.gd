extends "./material_detector.gd"

var all_possible_material_names: PackedStringArray = []

func detect(collider: Object, collision_point: Vector3) -> Variant:
	if collider == null:
		return null
	if not (collider is GridMap):
		return null

	var gridmap = collider as GridMap
	var local_pos = gridmap.to_local(collision_point)
	local_pos.y -= gridmap.cell_size.y
	var cell = gridmap.local_to_map(local_pos)
	return _detect_material(gridmap, cell)



func _detect_material(gridmap: GridMap, cell: Vector3i) -> Variant:
	var item_id = gridmap.get_cell_item(cell)
	if item_id == -1:
		return null

	var item_name = gridmap.mesh_library.get_item_name(item_id)
	if item_name in all_possible_material_names:
		return item_name
	return null
