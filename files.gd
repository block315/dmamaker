extends PopupMenu
class_name FileMenu

@onready var file_dialog: FileDialog = $FileDialog
@onready var graph_edit: GraphEdit = %GraphEdit
@onready var code_edit: CodeEdit = %CodeEdit
@onready var debug_label: Label = %DebugLabel
var file_access_web := FileAccessWeb.new()
@export var save_file_path_for_web: String = "/save_test.dma" 

func _ready() -> void:
	add_item("New", 0, KEY_MASK_CTRL|KEY_N)
	add_item("Import",1, KEY_MASK_CTRL|KEY_O)
	add_item("Export",2, KEY_MASK_CTRL|KEY_S)
	add_item("Exit",3, KEY_MASK_CTRL|KEY_Q)

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
	print("Web Import working.")
	var parser = XMLParser.new()
	debug_label.text += "File loaded"
	debug_label.text += Marshalls.base64_to_utf8(base64_data)
	parser.open_buffer(Marshalls.base64_to_raw(base64_data))
	dma_parser(parser)

func _on_error() -> void:
	print("error")
	debug_label.text += "Error"

func _on_progress():
	pass

func _on_upload_cancelled():
	pass

## make node graph from xml file
func dma_parser(parser):
	var _xml_stack = []
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT \
		and parser.get_node_name() == "mech":
			var _dma_node := DMANode.new()
			var _name = parser.get_attribute_value(0)
			_dma_node.resizable = true
			if graph_edit.get_node_or_null(_name) != null:
				_name += "*"
			_dma_node.name = _name
			graph_edit.add_child(_dma_node)
			if !_xml_stack.is_empty():
				_dma_node.add_child(Control.new())
				graph_edit.connect_node(_xml_stack.back(), 0, _name, 0)
			_xml_stack.append(_name)
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END \
		and parser.get_node_name() == "mech":
			_xml_stack.pop_back()
		graph_edit.arrange_nodes()

## for desktop import & export
func _on_file_dialog_file_selected(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		var parser = XMLParser.new()
		parser.open(path)
		dma_parser(parser)
	elif file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		FileAccess.open(path, FileAccess.WRITE).store_string(graph_edit.save(path).get_string_from_utf8())
	
