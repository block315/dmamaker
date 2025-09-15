extends "res://right_click_popup_menu.gd"

@onready var graph_edit: GraphEdit = get_parent()
var node_selected :Array[StringName] = []

func _ready() -> void:
	add_item("Add Node", 0, KEY_MASK_CTRL|KEY_A)
	add_item("Delete Node", 1, KEY_DELETE)
	add_separator("", 2)
	add_check_item("See Image", 3, KEY_SPACE)
	set_item_checked(3, true)

func _process(delta: float) -> void:
	pass

func _on_graph_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		position = event.global_position
		show()

func _on_id_pressed(id: int) -> void:
	match id:
		0:
			get_tree().get_first_node_in_group("nodes").show()
		1:
			graph_edit._on_delete_nodes_request(node_selected)
		3:
			toggle_item_checked(3)
			graph_edit.thumbnail = is_item_checked(3)


func _on_graph_edit_node_selected(node: Node) -> void:
	node_selected.append(node.name)


func _on_graph_edit_node_deselected(node: Node) -> void:
	node_selected.erase(node.name)

func _on_visibility_changed() -> void:
	set_item_text(0, "Add Node {0}".format([graph_edit.node_index]))
