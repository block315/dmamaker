extends PopupMenu

func _ready() -> void:
	add_item("About DMA Maker", 0)
	set_item_icon(0, load("uid://du6sqk8hmis6b"))
	for i in range(item_count):
		set_item_icon_max_width(i, ProgramConfig.icon_size)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
