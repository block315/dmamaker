extends CheckButton
class_name SetCheckButton

@onready var library = get_tree().get_first_node_in_group("library")

func _ready() -> void:
	toggled.connect(_on_state_changed) 

func _on_state_changed(activate:bool):
	if activate:
		library.enabled_set.append(self.text)
	else:
		library.enabled_set.erase(self.text)
	library.make_tree(library.enabled_set)
