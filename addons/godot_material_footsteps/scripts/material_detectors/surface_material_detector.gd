extends "./material_detector.gd"

var all_possible_material_names: PackedStringArray = []
var caching: bool = true

var _valid_materials_set: Dictionary = {}
var _hit_cache: Dictionary = {}
var _geometry_cache: Dictionary = {}
var _geometry_surface_material_cache: Dictionary = {}
var _mesh_face_ranges_cache: Dictionary = {}


func detect(raycast: RayCast3D) -> Variant:
	var collider = raycast.get_collider()
	if not collider:
		return null

	var collider_id = collider.get_instance_id()
	var shape_id = raycast.get_collider_shape()
	var face_index = raycast.get_collision_face_index()

	var cached_material = _get_cached_hit_material(collider_id, shape_id, face_index)
	if cached_material != null:
		return cached_material if cached_material != "" else null

	var geometry = _resolve_geometry(collider)
	if not geometry:
		_cache_hit_material(collider_id, shape_id, face_index, null)
		return null

	var material_name = _detect_geometry_material(geometry, face_index)
	_cache_hit_material(collider_id, shape_id, face_index, material_name)
	return material_name


func clear_cache() -> void:
	_hit_cache.clear()
	_geometry_cache.clear()
	_geometry_surface_material_cache.clear()
	_mesh_face_ranges_cache.clear()


func _detect_geometry_material(geometry: GeometryInstance3D, face_index: int) -> Variant:
	_ensure_materials_set_initialized()

	var override_material = geometry.material_override
	var override_name = _material_to_name(override_material)
	if override_name:
		return override_name

	if not (geometry is MeshInstance3D):
		return null

	var mesh_instance = geometry as MeshInstance3D
	var mesh = mesh_instance.mesh
	if not mesh:
		return null

	var surface_index = _get_surface_index_for_face(mesh, face_index)
	if surface_index < 0:
		return null

	return _get_or_cache_surface_material_name(mesh_instance, surface_index)


func _get_surface_index_for_face(mesh: Mesh, face_index: int) -> int:
	if face_index < 0:
		return 0 if mesh.get_surface_count() == 1 else -1

	var mesh_id = mesh.get_instance_id()
	var ranges = _mesh_face_ranges_cache.get(mesh_id)
	if ranges == null:
		ranges = _build_face_ranges(mesh)
		if caching:
			_mesh_face_ranges_cache[mesh_id] = ranges

	var surface_count = ranges.size()
	for surface_index in range(surface_count):
		if face_index < ranges[surface_index]:
			return surface_index

	return -1


func _build_face_ranges(mesh: Mesh) -> PackedInt32Array:
	var ranges := PackedInt32Array()
	var running_total = 0
	var surface_count = mesh.get_surface_count()

	for surface_index in range(surface_count):
		var index_count = mesh.surface_get_array_index_len(surface_index)
		var triangle_count = index_count / 3
		if triangle_count == 0:
			var vertex_count = mesh.surface_get_array_len(surface_index)
			triangle_count = vertex_count / 3
		running_total += triangle_count
		ranges.append(running_total)

	return ranges


func _get_or_cache_surface_material_name(mesh_instance: MeshInstance3D, surface_index: int) -> Variant:
	if not caching:
		return _material_to_name(_get_surface_material(mesh_instance, surface_index))

	var geometry_id = mesh_instance.get_instance_id()
	if not _geometry_surface_material_cache.has(geometry_id):
		_geometry_surface_material_cache[geometry_id] = {}

	var per_surface_cache = _geometry_surface_material_cache[geometry_id]
	if per_surface_cache.has(surface_index):
		var cached_material = per_surface_cache[surface_index]
		return cached_material if cached_material != "" else null

	var material_name = _material_to_name(_get_surface_material(mesh_instance, surface_index))
	per_surface_cache[surface_index] = material_name if material_name else ""
	return material_name


func _get_surface_material(mesh_instance: MeshInstance3D, surface_index: int) -> Material:
	var active_material = mesh_instance.get_active_material(surface_index)
	if active_material:
		return active_material

	var mesh = mesh_instance.mesh
	if mesh:
		return mesh.surface_get_material(surface_index)

	return null


func _material_to_name(material: Material) -> Variant:
	if not material:
		return null

	if _is_valid_material_name(material.resource_name):
		return material.resource_name

	if material.resource_path:
		var path_name = material.resource_path.get_file().get_basename()
		if _is_valid_material_name(path_name):
			return path_name

	return null


func _is_valid_material_name(material_name: String) -> bool:
	if material_name == "":
		return false
	if _valid_materials_set.is_empty():
		return true
	return _valid_materials_set.has(material_name)


func _resolve_geometry(collider: Object) -> GeometryInstance3D:
	if collider is GeometryInstance3D:
		return collider as GeometryInstance3D

	if not (collider is Node):
		return null

	var collider_id = collider.get_instance_id()
	if caching and _geometry_cache.has(collider_id):
		var cached_geometry = _geometry_cache[collider_id]
		if is_instance_valid(cached_geometry):
			return cached_geometry
		_geometry_cache.erase(collider_id)

	var geometry = _find_geometry_in_subtree(collider)
	if caching and geometry:
		_geometry_cache[collider_id] = geometry

	return geometry


func _find_geometry_in_subtree(root: Node) -> GeometryInstance3D:
	var stack: Array[Node] = [root]

	while not stack.is_empty():
		var node = stack.pop_back()
		if node is GeometryInstance3D:
			return node as GeometryInstance3D

		for child in node.get_children():
			if child is Node:
				stack.append(child)

	return null


func _get_cached_hit_material(collider_id: int, shape_id: int, face_index: int) -> Variant:
	if not caching:
		return null
	if not _hit_cache.has(collider_id):
		return null

	var per_collider_cache = _hit_cache[collider_id]
	var hit_key = _pack_hit_key(shape_id, face_index)
	if per_collider_cache.has(hit_key):
		return per_collider_cache[hit_key]

	return null


func _cache_hit_material(collider_id: int, shape_id: int, face_index: int, material_name: Variant) -> void:
	if not caching:
		return

	if not _hit_cache.has(collider_id):
		_hit_cache[collider_id] = {}

	var per_collider_cache = _hit_cache[collider_id]
	var hit_key = _pack_hit_key(shape_id, face_index)
	per_collider_cache[hit_key] = material_name if material_name else ""


func _pack_hit_key(shape_id: int, face_index: int) -> int:
	return (int(shape_id) << 32) ^ int(face_index & 0xffffffff)


func _ensure_materials_set_initialized() -> void:
	if _valid_materials_set.is_empty() and not all_possible_material_names.is_empty():
		for material_name in all_possible_material_names:
			_valid_materials_set[material_name] = true