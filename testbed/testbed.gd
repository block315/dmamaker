extends Node3D
class_name TestBed

@onready var physics_check_button: CheckButton = $"../../../HBoxContainer/PhysicsCheckButton"

func _ready() -> void:
	if get_parent().name == "TestBed":
		physics_check_button.connect("toggled", _on_check_button_toggled)

func _on_check_button_toggled(toggled_on: bool) -> void:
	set_physics_process(toggled_on)
	for _child in get_children():
		if _child is RigidBody3D:
			_child.freeze = !toggled_on
