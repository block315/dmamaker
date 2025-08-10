extends Tree

@export var enabled_set:Array[String] = []

const DMA_NODE = preload("res://dma_node.tscn")
var set_stack = {}

func _ready() -> void:
	make_tree()

func make_tree(enabled_set:Array[String]=["SetA"]):
	clear()
	var parser = XMLParser.new()
	var _tree_stack = []
	for _set_file in enabled_set:
		parser.open("res://library/set/%s.dmaset" % _set_file)
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			if parser.get_node_name() == "connection":
				set_stack[_tree_stack.back().get_text(0)].append(parser.get_attribute_value(0))
				continue
			var _tree_item = create_item(_tree_stack.back())
			_tree_item.add_button(0,load("res://LibraryButton.tres"))
			_tree_item.set_text(0, parser.get_attribute_value(0))
			set_stack[parser.get_attribute_value(0)] = []
			if parser.get_node_name() == "mech":
				set_stack[_tree_stack.back().get_text(0)].append(parser.get_attribute_value(0))
				_tree_stack.back().collapsed = true
			_tree_stack.append(_tree_item)
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "connection":
				continue
			_tree_stack.pop_back()

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	for _node in %Nodes.get_children():
		_node.queue_free()
	for _dma in set_stack[item.get_text(0)]:
		var _node = DMA_NODE.instantiate()
		_node.name = _dma
		var connection_index = 1
		for _connection in set_stack[_dma]:
			var _connection_color = Color(randf(), randf(), randf())
			var _port = Label.new()
			_port.text = _connection
			_port.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			_node.add_child(_port)
			_node.set_slot(connection_index, true, connection_index, _connection_color, \
				true, connection_index, _connection_color)
			connection_index += 1
		%Nodes.add_child(_node)
