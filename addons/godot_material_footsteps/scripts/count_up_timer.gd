extends RefCounted

var time: float = 0.0
var _is_running: bool = false

func update(delta: float) -> void:
	if _is_running:
		time += delta

func start() -> void:
	_is_running = true

func stop() -> void:
	_is_running = false
	reset()

func reset() -> void:
	time = 0.0

func is_elapsed(threshold: float) -> bool:
	return time >= threshold

func get_time() -> float:
	return time

func is_running() -> bool:
	return _is_running
