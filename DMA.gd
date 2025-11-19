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
