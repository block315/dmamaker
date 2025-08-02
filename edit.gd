extends PopupMenu

func _ready() -> void:
	add_item("Config", 0, KEY_MASK_CTRL|KEY_COMMA)

func _process(delta: float) -> void:
	pass
