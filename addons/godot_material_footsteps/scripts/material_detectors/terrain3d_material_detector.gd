extends "./material_detector.gd"

var terrain3d :Terrain3D
var tex_id :Vector3
var tex_id_string :String

func _init(terrain3d_ref) -> void:
	terrain3d = terrain3d_ref


func detect(raycast: RayCast3D) -> Variant:
	if raycast.get_collider():
		var tex_id = terrain3d.data.get_texture_id(raycast.get_collision_point())
		tex_id_string = str(tex_id.x)
		return tex_id_string
	else:
		return null
