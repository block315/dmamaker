extends PopupMenu
class_name FileMenu

@onready var file_dialog: FileDialog = $FileDialog
@onready var graph_edit: GraphEdit = get_tree().get_first_node_in_group("graph")
@onready var code_edit: CodeEdit = %CodeEdit
@onready var debug_label: Label = %DebugLabel
var file_access_web := FileAccessWeb.new()
@export var save_file_path_for_web: String = "/save_test.dma" 

func _ready() -> void:
	add_item("New", 0, KEY_MASK_CTRL|KEY_N)
	set_item_icon(0, load("res://arts/kenney_game-icons/PNG/White/1x/door.png"))
	add_item("Import",1, KEY_MASK_CTRL|KEY_O)
	set_item_icon(1, load("res://arts/kenney_game-icons/PNG/White/1x/import.png"))
	add_item("Export",2, KEY_MASK_CTRL|KEY_S)
	set_item_icon(2, load("res://arts/kenney_game-icons/PNG/White/1x/save.png"))
	add_item("Exit",3, KEY_MASK_CTRL|KEY_Q)
	set_item_icon(3, load("res://arts/kenney_game-icons/PNG/White/1x/cross.png"))
	for i in range(item_count):
		set_item_icon_max_width(i, ProgramConfig.icon_size)

func _on_id_pressed(id: int) -> void:
	match id:
		0:
			get_tree().reload_current_scene()
		1:
			file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			graph_edit.graph_flush()
			if OS.get_name() == "Web":
				file_access_web.loaded.connect(on_file_loaded)
				file_access_web.error.connect(_on_error)
				file_access_web.open(".dma")
				file_access_web.progress.connect(_on_progress)
				file_access_web.upload_cancelled.connect(_on_upload_cancelled)
			else:
				file_dialog.show()
		2:
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			if OS.get_name() == "Web":
				JavaScriptBridge.download_buffer(graph_edit.save(), "test.dma", "application/xml")
			else:
				file_dialog.show()
		3:
			get_tree().quit()

## for web import
func on_file_loaded(file_name: String, file_type: String, base64_data: String) -> void:
	var parser = XMLParser.new()
	parser.open_buffer(Marshalls.base64_to_raw(base64_data))
	dma_parser(parser)

func _on_error() -> void:
	debug_label.text += "Error"

func _on_progress():
	pass

func _on_upload_cancelled():
	pass

## make node graph from xml file
func dma_parser(parser: XMLParser):
	#var _xml_stack = []
	#var _node_stack = []
	#while parser.read() != ERR_FILE_EOF:
		## make dma_node and xml_stack
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			#and parser.get_node_name() == "mech":
			#var _dma_node := DMANode.new()
			#var _name = parser.get_named_attribute_value("name")
			#var _index = parser.get_named_attribute_value("index")
			#var _connection = parser.get_named_attribute_value("connection")
			#_dma_node.resizable = true
			#if graph_edit.get_node_or_null(_name) != null:
				#continue
			#_name += (ProgramConfig.index_split_symbol + _index)
			#if !graph_edit.get_node(_name):
				#_dma_node.name = _name
				#graph_edit.add_child(_dma_node)
			#else:
				#_dma_node = graph_edit.get_node(_name)
			#if !_xml_stack.is_empty():
				##var _control_for_conn := Label.new()
				##_control_for_conn.text = _connection
				##_dma_node.add_child(_control_for_conn)
				#graph_edit.connect_node(_xml_stack.back(), 0, _name, 0)
				##print("connecting to ", _control_for_conn.get_index())
			#_xml_stack.append(_name)
			#_node_stack.append(_dma_node)
		## add ports to dma_node
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			#and parser.get_node_name() == "connection":
			#var _connection_name = parser.get_named_attribute_value("name")
			#var _connection_type = parser.get_named_attribute_value("type")
			#var _control_for_conn := Label.new()
			#var already_created :bool = false
			#var _dma_node_for_port: DMANode = _node_stack.back()
			#for _port in _node_stack.back().get_children():
				#if _port is Label and _port.name == _connection_name:
					#already_created = true
			#if !already_created:
				#_control_for_conn.text = _connection_name
				#_dma_node_for_port.add_child(_control_for_conn)
				#_dma_node_for_port.set_slot_type_left(_control_for_conn.get_index(), int(_connection_type))
				#_dma_node_for_port.set_slot_enabled_left(_control_for_conn.get_index(), true)
				#_dma_node_for_port.set_slot_type_right(_control_for_conn.get_index(), int(_connection_type))
				#_dma_node_for_port.set_slot_enabled_right(_control_for_conn.get_index(), true)
		#if parser.get_node_type() == XMLParser.NODE_ELEMENT_END \
			#and parser.get_node_name() == "mech":
			#_xml_stack.pop_back()
			#_node_stack.pop_back()
		DMA.parser_to_node(parser)
		graph_edit.arrange_nodes()

## for desktop import & export
func _on_file_dialog_file_selected(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		var parser = XMLParser.new()
		parser.open(path)
		dma_parser(parser)
	elif file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		FileAccess.open(path, FileAccess.WRITE).store_string(graph_edit.save(path).get_string_from_utf8())
