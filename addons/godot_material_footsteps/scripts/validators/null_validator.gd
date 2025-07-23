extends "./validator.gd"

var required_variables: Dictionary[String, Variant] = {}


func _init(variables: Dictionary[String, Variant]) -> void:
	required_variables = variables


func validate() -> bool:
	var checks_passed: bool = true
	for variable in required_variables.keys():
		if not required_variables[variable]:
			push_error("[NullValidator] %s is null and it must be set." % [str(variable)])
			checks_passed = false
	return checks_passed
