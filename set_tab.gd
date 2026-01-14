extends VBoxContainer

var mech_set_index_data: PackedStringArray

func _ready() -> void:
	for _child in get_children():
		_child.queue_free()
	if OS.get_name() == "Web":
		mech_set_index_data = JavaScriptBridge.eval('
			const xmlhttp = new XMLHttpRequest();
			xmlhttp.open("GET", "/media/set/dmaset.txt", false);
			xmlhttp.send();
			if (xmlhttp.status==200) {xmlhttp.response;}').split('\n')
	else:
		var set_dir = DirAccess.open("library/set")
		mech_set_index_data = []
		for _files in set_dir.get_files():
			mech_set_index_data.append(_files.trim_suffix(".dmaset"))
	for _set in mech_set_index_data:
		var _set_check_button = SetCheckButton.new()
		_set_check_button.text = _set

		#print(_set)
		add_child(_set_check_button)
