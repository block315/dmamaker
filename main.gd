extends Control

@onready var popup_menu: PopupMenu = $PopupMenu
@onready var node_to_rightclick = self


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#func _process(delta: float) -> void:
	#node_to_rightclick = get_viewport().gui_get_focus_owner()
	#print(node_to_rightclick)
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		#if node_to_rightclick and !node_to_rightclick.has_method("get_menu"):
			#popup_menu.position = get_global_mouse_position()
			#popup_menu._on_about_to_popup()
			#popup_menu.show()
