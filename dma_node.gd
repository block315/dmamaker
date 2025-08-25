extends GraphNode
class_name DMANode

@export var texture:Texture = preload("res://icon.svg")
@onready var graph:GraphEdit = get_tree().get_first_node_in_group("graph")
var mouse_selected: bool = false

func _init() -> void:
	var _label : Label = get_titlebar_hbox().get_child(0)
	_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func _ready() -> void:
	renamed.connect(_on_renamed)
	slot_updated.connect(_on_slot_updated)
	_on_renamed()
	_on_slot_updated()
	custom_minimum_size = Vector2(100,100)
	for _node_component in get_children():
		if _node_component is TextureRect:
			return
	var _texture := TextureRect.new()
	_texture.texture = texture
	_texture.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	add_child(_texture)
	move_child(_texture, 0)

func _process(delta: float) -> void:
	if mouse_selected:
		global_position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
			and graph.get_rect().has_point(get_global_mouse_position()):
			mouse_selected = false
			name += (ProgramConfig.index_split_symbol + str(graph.node_index))
			reparent(graph)
			position_offset = graph.get_local_mouse_position()
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			queue_free()

func _on_renamed() -> void:
	title = name

func _on_slot_updated():
	for i in range(get_input_port_count()+1):
		set_slot_enabled_left(i,true)
	for i in range(get_output_port_count()+1):
		set_slot_enabled_right(i, true)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and get_parent() is FlowContainer:
		if event.button_index == 1 and event.is_pressed():
			var _new_node = duplicate()
			_new_node.mouse_selected = true
			get_tree().get_root().add_child(_new_node)
