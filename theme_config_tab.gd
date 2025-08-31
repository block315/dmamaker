extends MarginContainer

var MAIN_THEME :Theme = preload("res://main_theme.tres")

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_check_box_pressed() -> void:
	pass # Replace with function body.

func _on_font_h_slider_value_changed(value: float) -> void:
	MAIN_THEME.default_font_size = value

func _on_uih_slider_value_changed(value: float) -> void:
	MAIN_THEME.default_base_scale = value
