extends GraphNode
class_name DMANode

enum IMAGEFORMAT {JPG, PNG, SVG}

@export var texture: ImageTexture = ImageTexture.create_from_image(preload("res://icon.svg").get_image())
var thumbnail: TextureRect
@onready var graph_edit: GraphEdit = get_tree().get_first_node_in_group("graph")
@onready var threed_view: View3D = get_tree().get_first_node_in_group("view3d")
@onready var text_edit: TextEdit = get_tree().get_first_node_in_group("textedit")

var mouse_selected: bool = false
var title_label: Label
var description: String
var pic: String = ""
@export var thumbnail_format: IMAGEFORMAT = IMAGEFORMAT.JPG

func _init() -> void:
	title_label = get_titlebar_hbox().get_child(0)
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if thumbnail == null:
		thumbnail = TextureRect.new()

func _ready() -> void:
	print("preparing dma ndoe")
	renamed.connect(_on_renamed)
	slot_updated.connect(_on_slot_updated)
	node_selected.connect(_on_node_selected)
	node_deselected.connect(_on_node_deselected)
	_on_renamed()
	_on_slot_updated()
	custom_minimum_size = Vector2(100,100)
	for _node_component in get_children():
		if _node_component is TextureRect:
			return
	if pic == "":
		thumbnail.texture = texture
	elif pic.begins_with("http"):
		if pic.ends_with("jpg"):
			thumbnail_format = IMAGEFORMAT.JPG
		elif pic.ends_with("png"):
			thumbnail_format = IMAGEFORMAT.PNG
		elif pic.ends_with("svg"):
			thumbnail_format = IMAGEFORMAT.SVG
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(self._http_request_completed)
		var error = http_request.request(pic)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
		print(http_request)
		if thumbnail.texture == null:
			thumbnail.texture = texture
	thumbnail.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	add_child(thumbnail)
	move_child(thumbnail, 0)

func _http_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image couldn't be downloaded. Try a different image.")
	var _image = Image.new()
	if thumbnail_format == IMAGEFORMAT.JPG:
		_image.load_jpg_from_buffer(body)
	elif thumbnail_format == IMAGEFORMAT.PNG:
		_image.load_png_from_buffer(body)
	elif thumbnail_format == IMAGEFORMAT.SVG:
		_image.load_svg_from_buffer(body)
	print(_image, "requset complete")
	print(texture)
	thumbnail.texture = ImageTexture.create_from_image(_image)

func _process(_delta: float) -> void:
	if mouse_selected:
		global_position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
			and graph_edit.get_rect().has_point(get_global_mouse_position()):
			mouse_selected = false
			name += (ProgramConfig.index_split_symbol + str(graph_edit.node_index))
			reparent(graph_edit)
			position_offset = graph_edit.get_local_mouse_position() + graph_edit.scroll_offset
			var _3d_representation = MeshInstance3D.new()
			_3d_representation.mesh = STLIO.Importer.LoadFromPath('res://library/3dmodels/motormeshfortest.stl')
			threed_view.add_child(_3d_representation)
			_3d_representation.scale = Vector3(.1,.1,.1)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			queue_free()

func _on_renamed() -> void:
	title = name
	var _label_text = title_label.text.split("-",true,2)
	if _label_text.size() > 1:
		title_label.text = str(_label_text[0]) + "\n" + str(_label_text[1])

func _on_slot_updated():
	set_slot_enabled_left(0, true)
	for i in range(1, get_input_port_count()+1):
		set_slot_enabled_left(i, false)
	for i in range(get_output_port_count()+1):
		set_slot_enabled_right(i, true)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and get_parent() is FlowContainer:
		if event.button_index == 1 and event.is_pressed():
			var _new_node = duplicate()
			_new_node.mouse_selected = true
			get_tree().get_root().add_child(_new_node)

func _on_node_selected() -> void:
	text_edit.text = description
	print("Node selected : ", description)

func _on_node_deselected() -> void:
	if text_edit.text != null:
		description = text_edit.text
