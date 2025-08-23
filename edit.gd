extends PopupMenu

@onready var config_popup_panel: PopupPanel = $ConfigPopupPanel

func _ready() -> void:
	add_item("Config", 0, KEY_MASK_CTRL|KEY_COMMA)

func _process(delta: float) -> void:
	pass


func _on_id_pressed(id: int) -> void:
	match id:
		0:
			config_popup_panel.show()
