extends RefCounted


func validate() -> bool:
	push_error("validate() must be overridden in subclass")
	return false
