extends Node

@onready var graph_edit: GraphEdit = get_tree().get_first_node_in_group("graph")

func parser_to_node(parser: XMLParser):
	var _xml_node_stack = []
	var node_index = 0
	var _node_stack = []
	var _connection: String
	var _connection_name: String
	var _dma_node: DMANode
	var _geometry_for_visual = true
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
			_dma_node.description = parser.get_named_attribute_value("name")
			for _ports in ["revolute", "continuous", "prismatic", "fixed", "floating", "planar"]:
				var _label = Label.new()
				_label.name = _ports
				_label.text = _ports
				_dma_node.add_child(_label)
				_dma_node.set_slot_enabled_right(_label.get_index(), true)
			graph_edit.add_child(_dma_node)
