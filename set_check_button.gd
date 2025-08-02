extends CheckButton
class_name SetCheckButton

func _ready() -> void:
	toggled.connect(_on_state_changed)

func _process(delta: float) -> void:
	pass

func _on_state_changed(activate:bool):
	print("toggle signal emitted")
	if activate:
		%Library.enabled_set.append(self.name)
		print(%Library.enabled_set)
	else:
		%Library.enabled_set.erase(self.name)
		print(%Library.enabled_set)
