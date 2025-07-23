extends RefCounted

var handlers: Array[Callable] = []


func add_handler(handler: Callable) -> void:
	handlers.append(handler)


func handle(args: Array) -> Variant:
	for handler in handlers:
		var result = handler.callv(args)
		if result != null:
			return result
	return null
