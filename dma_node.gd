extends GraphNode
class_name DMANode

@export var texture:Texture = preload("res://icon.svg")

func _ready() -> void:
	renamed.connect(_on_renamed)
	slot_updated.connect(_on_slot_updated)
	_on_renamed()
	_on_slot_updated()
	custom_minimum_size = Vector2(80,80)
	var _texture := TextureRect.new()
	_texture.texture = texture
	_texture.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	add_child(_texture)

func _process(delta: float) -> void:
	pass

func _on_renamed() -> void:
	title = name

func _on_slot_updated():
	#print("preparing slots...", get_input_port_count())
	for i in range(get_input_port_count()+1):
		set_slot_enabled_left(i,true)
		#print(i, "slot enabled")
	for i in range(get_output_port_count()+1):
		set_slot_enabled_right(i, true)
