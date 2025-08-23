extends SubViewportContainer
class_name View3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera_3d: Camera3D = $SubViewport/Camera3D
@export var camera_sensitivity :float = .1
@onready var graph_edit: GraphEdit = %GraphEdit
@onready var test_bed: Node3D = $SubViewport/TestBed

func _process(delta: float) -> void:
	if visible:
		var camera_control = Input.get_vector("left", "right", "forward", "backward")
		camera_3d.position += camera_sensitivity * Vector3(camera_control.x, Input.get_axis("down", "up"), camera_control.y)

func _on_graph_edit_child_order_changed() -> void:
	if sub_viewport == null:
		return
	for _visual in sub_viewport.get_children():
		if _visual is CSGBox3D:
			_visual.queue_free()
	for _node in graph_edit.get_children():
		if _node is GraphNode:
			var _node_visiual_body = RigidBody3D.new()
			_node_visiual_body.freeze = true
			var _node_visiual = CSGBox3D.new()
			test_bed.get_child(0).add_child(_node_visiual_body)
			_node_visiual_body.position = Vector3(randi_range(-5,5), randi_range(-5,5), randi_range(-5,5))
			var _node_visiual_body_coll = CollisionShape3D.new()
			_node_visiual_body_coll.shape = BoxShape3D.new()
			_node_visiual_body.add_child(_node_visiual_body_coll)
			_node_visiual_body.add_child(_node_visiual)
			var _new_color = StandardMaterial3D.new()
			_new_color.albedo_color = Color(randf(), randf(), randf(), randf())
			_node_visiual.material_override = _new_color

func _on_option_button_item_selected(index: int) -> void:
	test_bed.get_child(0).queue_free()
	match index:
		0:
			test_bed.add_child(preload("res://testbed/empty.tscn").instantiate())
		1:
			test_bed.add_child(preload("res://testbed/plane.tscn").instantiate())
	test_bed.get_child(0)._ready()
