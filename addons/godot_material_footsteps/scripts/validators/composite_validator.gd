extends "./validator.gd"

const Validator = preload("./validator.gd")
var required_validators: Array[Validator] = []


func _init(validators: Array[Validator]) -> void:
	required_validators = validators


func add_validator(validator: Validator) -> void:
	required_validators.append(validator)


func validate() -> bool:
	var checks_passed: bool = true
	for validator in required_validators:
		if validator.validate() == false:
			push_error("[CompositeValidator] Validation has failed")
			checks_passed = false
	return checks_passed
