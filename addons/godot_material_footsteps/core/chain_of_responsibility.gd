extends RefCounted
class_name ChainOfResponsibility

var handlers: Array[Callable]

func add_handler(handler: Callable) -> void:
	handlers.append(handler)

func handle(context) -> Variant:
	for handler in handlers:
		var result = handler.call(context)
		if result != null:
			return result
	return null
