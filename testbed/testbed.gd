extends Node3D
class_name TestBed

@onready var physics_check_button: CheckButton = $"../../../HBoxContainer/PhysicsCheckButton"
@onready var graph_edit: GraphEdit = get_tree().get_first_node_in_group("graph")
@onready var _3d_view: View3D = get_tree().get_first_node_in_group("view3d")


func _ready() -> void:
	if get_parent().name == "TestBed":
		physics_check_button.connect("toggled", _on_check_button_toggled)
		_3d_view._on_graph_edit_child_order_changed()

func _on_check_button_toggled(toggled_on: bool) -> void:
	set_physics_process(toggled_on)
	for _child in get_children():
		if _child is RigidBody3D:
			_child.freeze = !toggled_on
