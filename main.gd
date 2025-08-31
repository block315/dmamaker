extends Control

@onready var popup_menu: PopupMenu = $PopupMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		popup_menu.position = get_global_mouse_position()
		popup_menu._on_about_to_popup()
		popup_menu.show()
