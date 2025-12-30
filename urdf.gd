extends Node

@onready var graph_edit: GraphEdit = get_tree().get_first_node_in_group("graph")

func parser_to_node(parser: XMLParser):
	var _xml_node_stack = []
	var _node_index = 1
	var _new_node_name = {}
	var _connection: String
	var _connection_name: String
	var _dma_node: DMANode
	var _joint_type: String
	var _parent: String
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			_xml_node_stack.append(parser.get_node_name())
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			_xml_node_stack.pop_back()
		## make node and ports
		if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			and parser.get_node_name() == "link":
			_dma_node = DMANode.new()
			_dma_node.resizable = true
			_dma_node.name = parser.get_named_attribute_value("name") + (ProgramConfig.index_split_symbol + str(_node_index))
			_node_index += 1
			for _ports in ["revolute", "continuous", "prismatic", "fixed", "floating", "planar"]:
				var _label = Label.new()
				_label.name = _ports
				_label.text = _ports
				_dma_node.add_child(_label)
				_dma_node.set_slot_enabled_right(_label.get_index(), true)
			graph_edit.add_child(_dma_node)
			_new_node_name[parser.get_named_attribute_value("name")] = _dma_node.name
	parser.seek(0)
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			and parser.get_node_name() == "joint":
				_joint_type = parser.get_named_attribute_value("type")
		if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			and parser.get_node_name() == "parent":
				_parent = parser.get_named_attribute_value("link")
		if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			and parser.get_node_name() == "child":
				graph_edit.connect_node(
					_new_node_name[_parent], graph_edit.get_node(NodePath(_new_node_name[_parent]+"/"+_joint_type)).get_index(),\
					_new_node_name[parser.get_named_attribute_value("link")], 0)
