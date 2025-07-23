extends RefCounted

signal landed(fall_speed: float)

var was_on_floor := false
var fall_speed := 0.0


func update(character: CharacterBody3D) -> void:
	var is_on_floor = character.is_on_floor()
	var velocity = character.velocity
	if not was_on_floor and is_on_floor:
		fall_speed = abs(velocity.y)
		emit_signal("landed", fall_speed)
	else:
		fall_speed = 0.0

	was_on_floor = is_on_floor
