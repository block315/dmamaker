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
	DMA.parser_to_node(parser)
	graph_edit.arrange_nodes()

func _on_error() -> void:
	debug_label.text += "Error"

func _on_progress():
	pass

func _on_upload_cancelled():
	pass

## for desktop import & export
func _on_file_dialog_file_selected(path: String) -> void:
	if file_dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		var parser = XMLParser.new()
		parser.open(path)
		if path.ends_with(".dma"):
			DMA.parser_to_node(parser)
			graph_edit.arrange_nodes()
		elif path.ends_with(".urdf"):
			URDF.parser_to_node(parser)
			graph_edit.arrange_nodes()
	elif file_dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		if path.ends_with(".dma"):
			FileAccess.open(path, FileAccess.WRITE).store_string(graph_edit.save_to_dma(path).get_string_from_utf8())
		elif path.ends_with(".urdf"):
			FileAccess.open(path, FileAccess.WRITE).store_string(graph_edit.save_to_urdf(path).get_string_from_utf8())
