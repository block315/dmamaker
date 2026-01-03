extends Node

@onready var graph_edit: GraphEdit = get_tree().get_first_node_in_group("graph")

func parser_to_node(parser: XMLParser):
	var _node_stack = []
	var _connection_stack = []
	var _connection: String
	var _connection_name: String
	#var _connection_type: int
	var _dma_node: DMANode
	## make node and ports
	while parser.read() != ERR_FILE_EOF:
		## make node
		if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			and parser.get_node_name() == "mech":
			_dma_node = DMANode.new()
			var _node_name: String = parser.get_named_attribute_value("name")
			var _node_index: int = int(parser.get_named_attribute_value("index"))
			_dma_node.resizable = true
			#if graph_edit.get_node_or_null(_name) != null:
				#continue
			_node_name += (ProgramConfig.index_split_symbol + str(_node_index))
			## add node to graphedit & reusing node that is alreay in graphedit
			if !graph_edit.get_node(_node_name):
				_dma_node.name = _node_name
				graph_edit.add_child(_dma_node)
			else:
				_dma_node = graph_edit.get_node(_node_name)
			_node_stack.append(_dma_node)
			#print(_node_stack)
		if parser.get_node_type() == XMLParser.NODE_TEXT \
			and not _node_stack.is_empty():
			var _description: String = parser.get_node_data().strip_escapes().lstrip(" ").rstrip(" ")
			if _description != "":
				print(_description)
				_node_stack.back().description = _description
		## make ports for node
		if parser.get_node_type() == XMLParser.NODE_ELEMENT \
			and parser.get_node_name() == "conn":
			_connection_name = parser.get_named_attribute_value("name")
			_connection_stack.append(_connection_name)
			print(_connection_stack)
			var _control_for_conn := Label.new()
			var already_created := false
			var _node_for_port: DMANode = _node_stack.back()
			for _port in _node_stack.back().get_children():
				if _port is Label and _port.text == _connection_name:
					already_created = true
			if not already_created:
				_control_for_conn.text = _connection_name
				_control_for_conn.name = _connection_name
				_node_for_port.add_child(_control_for_conn)
				_node_for_port.set_slot_enabled_left(_control_for_conn.get_index(), false)
				_node_for_port.set_slot_enabled_right(_control_for_conn.get_index(), true)
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END \
		and parser.get_node_name() == "conn":
			_connection_stack.pop_back()
			print("poping _connection_stack")
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT_END \
		and parser.get_node_name() == "mech":
			#print(_connection_stack, " mech exit ", _node_stack)
			_dma_node = _node_stack.pop_back()
			## connect nodes
			if not _node_stack.is_empty() and not _connection_stack.is_empty():
				#var _control_for_conn := Label.new()
				#_control_for_conn.text = _connection
				#_dma_node.add_child(_control_for_conn)
				var _parent_node = _node_stack.back()
				print("connecting : ", _connection_stack.back(), parser.get_node_data(), _dma_node.get_children(), _dma_node.get_node("./"+(parser.get_node_data())).get_index())
				print(parser.get_node_data())
				graph_edit.connect_node(
					_parent_node.name, _parent_node.get_node(_connection_stack.back()).get_index(),\
					_dma_node.name, 0 # _dma_node.get_node("./"+(parser.get_node_data())).get_index()-2
				)

func node_to_string(_path: String = "") -> PackedByteArray:
	var _xml_nodes = [] # XMLNode
	var _graph_nodes = [] # GraphNode
	var xml_list = [] # all xml data in xml file
	var xml_doc = XMLDocument.new()

	xml_doc.root = XMLNode.new()
	xml_doc.root.name = "dma"
	
	## make xml_nodes for dma_nodes in graphedit
	for _graph_node in graph_edit.get_children():
		if _graph_node is not GraphNode:
			continue
		var _xml_node := XMLNode.new()
		_xml_node.name = "mech"
		_xml_node.attributes = {"name": _graph_node.name}
		_xml_nodes.append(_xml_node)
		_graph_nodes.append(_graph_node)
		## add xml_nodes for connections
		for _graph_node_port in _graph_node.get_children():
			if _graph_node_port is not Label:
				continue
			var _xml_port_node := XMLNode.new()
			_xml_port_node.name = "conn"
			_xml_port_node.attributes = {"name": _graph_node_port.text, "type": _graph_node.get_output_port_type(_graph_node_port.get_index())}
			_xml_node.children.append(_xml_port_node)
	
	## add child dma_node
	for _parent_xml_node: XMLNode in _xml_nodes:
		for _connection in graph_edit.connections:
			if _parent_xml_node.attributes["name"] == _connection["from_node"]:
				for _child_xml_node: XMLNode in _xml_nodes:
					if _child_xml_node.attributes["name"] == _connection["to_node"]:
						#for _child_graph_node in _graph_nodes:
							#if _child_graph_node.name == _child_xml_node.attributes["name"]:
								#var _to_port_control_node = _child_graph_node.get_child(_connection["from_port"])
								#if _to_port_control_node is Label:
									#_child_xml_node.content = _to_port_control_node.text
						if _connection["from_port"] == 0:
							_parent_xml_node.children.append(_child_xml_node)
						else:
							_parent_xml_node.children[_connection["from_port"]-1].children.append(_child_xml_node)
						#for _parent_graph_node in _graph_nodes:
							#if _parent_graph_node.name == _parent_xml_node.attributes["name"]:
								#var _from_port_control_node = _parent_graph_node.get_child(_connection["from_port"])
								#if _from_port_control_node is Label:
									#_parent_xml_node.children[_connection["from_port"]].append(_child_xml_node)
								#else:
									#_child_xml_node.attributes["connection"] = "default"

	for _root_xml_node in _xml_nodes:
		var _has_parent := false
		for _connection in graph_edit.connections:
			if _root_xml_node.attributes["name"] == _connection["to_node"]:
				_has_parent = true
		if !_has_parent:
			xml_doc.root.children.append(_root_xml_node)
	
	xmldocuments_to_list(xml_doc.root, xml_list)
	for _xml_node in xml_list:
		if _xml_node.attributes.has("name") and _xml_node.attributes["name"].contains(ProgramConfig.index_split_symbol):
			var _xml_node_index = _xml_node.attributes["name"].split(ProgramConfig.index_split_symbol)[1]
			_xml_node.attributes["name"] = _xml_node.attributes["name"].split(ProgramConfig.index_split_symbol)[0]
			_xml_node.attributes["index"] = _xml_node_index
	return '<?xml version="1.0" encoding="UTF-8"?>\n'.to_utf8_buffer() + XML.dump_buffer(xml_doc,true)

func xmldocuments_to_list(root:XMLNode, xml_list):
	xml_list.append(root)
	for _child_node in root.children:
		xmldocuments_to_list(_child_node, xml_list)
