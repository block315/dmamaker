extends SubViewportContainer
class_name View3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera_3d: Camera3D = $SubViewport/Camera3D
@onready var ray_cast_3d: RayCast3D = $SubViewport/Camera3D/RayCast3D
@export var camera_sensitivity: float = .1
@onready var graph_edit: GraphEdit = %GraphEdit
@onready var test_bed: Node3D = $SubViewport/TestBed
var control_focus := false
@onready var bubble_timer: Timer = $BubbleTimer
var rng = RandomNumberGenerator.new()
@onready var mode_option_button: OptionButton = $HBoxContainer/ModeOptionButton

func _process(_delta: float) -> void:
	if visible and control_focus:
		var camera_control = Input.get_vector("left", "right", "forward", "backward")
		camera_3d.position += camera_3d.global_basis * camera_sensitivity * Vector3(camera_control.x, Input.get_axis("down", "up"), camera_control.y)
		match mode_option_button.selected:
			0:
				pass
			1:
				if Input.is_action_just_pressed("LC"):
					var _bubble_body = bubble()
					_bubble_body.global_position = ray_cast_3d.get_collision_point()
					test_bed.get_child(0).add_child(_bubble_body)
			2:
				if Input.is_action_just_pressed("LC"):
					if ray_cast_3d.is_colliding():
						var _collider = ray_cast_3d.get_collider()
						if _collider.get_parent() is TestBed:
							_collider.queue_free()

func _on_graph_edit_child_order_changed() -> void:
	if sub_viewport == null:
		return
	for _visual in test_bed.get_child(0).get_children():
			if _visual is RigidBody3D:
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

func _input(event) -> void:
	if event is InputEventMouseMotion and control_focus and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		camera_3d.rotate_y(-event.relative.x * 0.005)
		camera_3d.rotate_x(-event.relative.y * 0.005)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, -PI/4, PI/4)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			camera_3d.rotation = Vector3.ZERO
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Input.action_press("backward")
			await get_tree().create_timer(0.2).timeout
			Input.action_release("backward")
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Input.action_press("forward")
			await get_tree().create_timer(0.2).timeout
			Input.action_release("forward")

func _on_focus_entered() -> void:
	control_focus = true

func _on_focus_exited() -> void:
	control_focus = false

func bubble():
	var _body = RigidBody3D.new()
	var _body_visual = CSGSphere3D.new()
	var _collision = CollisionShape3D.new()
	var _collision_shape = BoxShape3D.new()
	_collision.shape = _collision_shape
	_body.add_child(_body_visual)
	_body.add_child(_collision)
	_body.freeze = true
	return _body

func _on_bubble_timer_timeout() -> void:
	if $HBoxContainer/BubbleButton.button_pressed:
		var _bubble_body = bubble()
		_bubble_body.global_position = Vector3(rng.randf_range(-5,5),rng.randf_range(-5,5), rng.randf_range(-5,5))
		test_bed.get_child(0).add_child(_bubble_body)
