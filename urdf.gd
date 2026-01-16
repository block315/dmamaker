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
				print("connecting", _parent)
				if _parent:
					graph_edit.connect_node(
						_new_node_name[_parent], graph_edit.get_node(NodePath(_new_node_name[_parent]+"/"+_joint_type)).get_index(),\
						_new_node_name[parser.get_named_attribute_value("link")], 0)

func node_to_string(_path: String = "") -> PackedByteArray:
	var _xml_nodes = [] # XMLNode
	var _graph_nodes = [] # GraphNode
	var xml_doc = XMLDocument.new()
	
	xml_doc.root = XMLNode.new()
	xml_doc.root.name = "robot"
	xml_doc.root.attributes = {"name": "visual"}
	
	## add link node
	for _graph_node in graph_edit.get_children():
		if _graph_node is not GraphNode:
			continue
		var _xml_node := XMLNode.new()
		_xml_node.name = "link"
		_xml_node.attributes = {"name": _graph_node.name.split(ProgramConfig.index_split_symbol)[0]}
		_xml_nodes.append(_xml_node)
		_graph_nodes.append(_graph_node)
		var _xml_visual_node := XMLNode.new()
		_xml_visual_node.name = "visual"
		_xml_node.children.append(_xml_visual_node)
		xml_doc.root.children.append(_xml_node)
	
	## add joint node
	for _connection in graph_edit.connections:
		var _xml_joint_node := XMLNode.new()
		_xml_joint_node.name = "joint"
		_xml_joint_node.attributes = {"type": "fixed"}
		var _xml_joint_child_node := XMLNode.new()
		_xml_joint_child_node.name = "child"
		_xml_joint_child_node.standalone = true
		_xml_joint_child_node.attributes = {"link": _connection["to_node"].split(ProgramConfig.index_split_symbol)[0]}
		var _xml_joint_parent_node := XMLNode.new()
		_xml_joint_parent_node.name = "parent"
		_xml_joint_parent_node.standalone = true
		_xml_joint_parent_node.attributes = {"link": _connection["from_node"].split(ProgramConfig.index_split_symbol)[0]}
		_xml_joint_node.children.append(_xml_joint_parent_node)
		_xml_joint_node.children.append(_xml_joint_child_node)
		xml_doc.root.children.append(_xml_joint_node)
	
	return '<?xml version="1.0" encoding="UTF-8"?>\n'.to_utf8_buffer() + XML.dump_buffer(xml_doc,true)
