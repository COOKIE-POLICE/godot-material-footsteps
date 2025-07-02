@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"MaterialFootstepPlayer3D",
		"RayCast3D",
		preload("res://addons/godot_material_footsteps/core/material_footstep_player_3d.gd"),
		preload("res://addons/godot_material_footsteps/assets/editor_icons/icon.png")
	)

func _exit_tree() -> void:
	remove_custom_type("MaterialFootstepPlayer3D")
