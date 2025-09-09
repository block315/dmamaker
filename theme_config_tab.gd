extends MarginContainer

var MAIN_THEME :Theme = preload("res://main_theme.tres")
@onready var color_picker_button: ColorPickerButton = $VBoxContainer/HBoxContainer3/ColorPickerButton

func _ready() -> void:
	color_picker_button.get_popup().always_on_top = true

func _process(delta: float) -> void:
	pass

func _on_check_box_pressed() -> void:
	pass # Replace with function body.

func _on_font_h_slider_value_changed(value: float) -> void:
	MAIN_THEME.default_font_size = value

func _on_uih_slider_value_changed(value: float) -> void:
	MAIN_THEME.default_base_scale = value

func _on_h_slider_value_changed(value: float) -> void:
	ProgramConfig.icon_size = value
