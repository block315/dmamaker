extends Tree
class_name Library

@export var enabled_set:Array[String] = []

const DMA_NODE = preload("res://dma_node.tscn")
var set_stack = {}

func _ready() -> void:
	make_tree()

func make_tree(enabled_set:Array[String]=["SetA"]):
	clear()
	if enabled_set.size() > 1:
		var _root = create_item()
		_root.set_text(0, "DMA sets")
	for _set_file in enabled_set:
		var parser = make_parser_from_file(_set_file)
		var _tree_stack = []
		while parser.read() != ERR_FILE_EOF:
			if parser.get_node_type() == XMLParser.NODE_ELEMENT:
				if parser.get_node_name() == "connection":
					set_stack[_tree_stack.back().get_text(0)].append([parser.get_attribute_value(0), parser.get_attribute_value(1)])
					continue
				var _tree_item = make_tree_item(_tree_stack, parser)
				update_set_stack(parser, _tree_stack)
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
		_node.set_slot(0, true, 0, Color8(rand_from_seed(0)[0]%256, \
			rand_from_seed(0)[0]/1000000%256,rand_from_seed(0)[0]/1000%256), \
			true, 0, Color8(rand_from_seed(0)[0]%256, \
			rand_from_seed(0)[0]/1000000%256,rand_from_seed(0)[0]/1000%256))
		for _connection in set_stack[_dma]:
			var connection_type = int(_connection[1])
			var _connection_color = Color8(rand_from_seed(connection_type)[0]%256, \
rand_from_seed(connection_type)[0]/1000000%256,rand_from_seed(connection_type)[0]/1000%256)
			print("adding port color ", _connection_color)
			var _port = Label.new()
			_port.text = _connection[0]
			_port.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			_node.add_child(_port)
			_node.set_slot(connection_index, true, connection_type, _connection_color, \
				true, connection_type, _connection_color)
			connection_index += 1
		%Nodes.add_child(_node)

func make_parser_from_file(_set_file) -> XMLParser:
	var parser = XMLParser.new()
	if OS.get_name() == "Web":
		parser.open_buffer(JavaScriptBridge.eval('
			const xmlhttp = new XMLHttpRequest();
			xmlhttp.open("GET", "/media/set/%s.dmaset", false);
			xmlhttp.send();
			if (xmlhttp.status==200) {xmlhttp.response;}' % _set_file).to_utf8_buffer())
	else:
		parser.open("res://library/set/%s.dmaset" % _set_file)
	return parser

func make_tree_item(_tree_stack, parser) -> TreeItem:
	var _tree_item = create_item(_tree_stack.back())
	var _tree_item_button = load("res://arts/kenney_game-icons/PNG/White/1x/cart.png")
	_tree_item_button.get_image().resize(1,1)
	_tree_item.add_button(0,_tree_item_button)
	_tree_item.get_button(0,0).get_image().resize(5,5)
	_tree_item.set_text(0, parser.get_attribute_value(0))
	return _tree_item

func update_set_stack(parser, _tree_stack):
	set_stack[parser.get_attribute_value(0)] = []
	if parser.get_node_name() == "mech":
		set_stack[_tree_stack.back().get_text(0)].append(parser.get_attribute_value(0))
		_tree_stack.back().collapsed = true
