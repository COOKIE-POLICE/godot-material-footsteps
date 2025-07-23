@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"MaterialFootstepPlayer3D",
		"RayCast3D",
		preload("core/material_footstep_player_3d.gd"),
		preload("assets/editor_icons/icon.png")
	)


func _exit_tree() -> void:
	remove_custom_type("MaterialFootstepPlayer3D")
