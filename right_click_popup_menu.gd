extends PopupMenu

var menu_to_make = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	hide()

func _on_about_to_popup() -> void:
	clear()
	for _menu in menu_to_make:
		add_item(_menu)
		print("menu making")
