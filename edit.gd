extends PopupMenu

@onready var config_popup_panel: PopupPanel = $ConfigPopupPanel

func _ready() -> void:
	add_item("Config", 0, KEY_MASK_CTRL|KEY_COMMA)
	set_item_icon(0, load("res://arts/kenney_game-icons/PNG/White/1x/gear.png"))
	for i in range(item_count):
		set_item_icon_max_width(i, ProgramConfig.icon_size)

func _process(delta: float) -> void:
	pass


func _on_id_pressed(id: int) -> void:
	match id:
		0:
			config_popup_panel.show()
