extends PopupMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_item("Record", 0)
	set_item_icon(0, load("uid://bvyj5qjjxl4vr"))
	for i in range(item_count):
		set_item_icon_max_width(i, ProgramConfig.icon_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
