extends PopupMenu

func _ready() -> void:
	close_requested.connect(hide)

func _process(delta: float) -> void:
	pass
