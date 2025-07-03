extends RefCounted

var time: float = 0.0

func update(delta: float) -> void:
	time += delta

func reset() -> void:
	time = 0.0

func is_elapsed(threshold: float) -> bool:
	return time >= threshold
