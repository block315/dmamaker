extends CheckButton
class_name SetCheckButton

@onready var library = get_tree().get_first_node_in_group("library")

func _ready() -> void:
	toggled.connect(_on_state_changed) 

func _process(delta: float) -> void:
	pass

func _on_state_changed(activate:bool):
	if activate:
		library.enabled_set.append(self.text)
		print(library.enabled_set)
	else:
		library.enabled_set.erase(self.text)
		print(library.enabled_set)
	library.make_tree(library.enabled_set)
