extends "./material_detector.gd"

#region CONFIGURATION
var all_possible_material_names: PackedStringArray = []
#endregion

#region PUBLIC API
func detect(raycast: RayCast3D) -> Variant:
	if raycast.get_collider() == null:
		return null
	if not (raycast.get_collider() is GridMap):
		return null

	var gridmap = raycast.get_collider() as GridMap
	var local_pos = gridmap.to_local(raycast.get_collision_point())
	local_pos.y -= gridmap.cell_size.y
	var cell = gridmap.local_to_map(local_pos)
	return _detect_material(gridmap, cell)
#endregion
#region PRIVATE METHODS
func _detect_material(gridmap: GridMap, cell: Vector3i) -> Variant:
	var item_id = gridmap.get_cell_item(cell)
	if item_id == -1:
		return null

	var item_name = gridmap.mesh_library.get_item_name(item_id)
	if item_name in all_possible_material_names:
		return item_name
	return null
#endregion
