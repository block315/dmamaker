extends GraphEdit

var node_index: int
var thumbnail: bool = true :
	set(value):
		node_thumbnail(value)
		thumbnail = value

func _ready() -> void:
	graph_flush()

func graph_flush():
	if get_child_count() > 0:
		for _graph_node in get_children():
			if _graph_node is GraphNode:
				_graph_node.queue_free()

func node_thumbnail(thumbnail:bool):
	if get_child_count() > 0:
		for _graph_node in get_children():
			if _graph_node is DMANode:
				for _node_component in _graph_node.get_children():
					if _node_component is TextureRect:
						if thumbnail:
							_node_component.scale.y = 1
							_graph_node.reset_size()
						else:
							_node_component.scale.y = 0
							_graph_node.reset_size()

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	connect_node(from_node, from_port, to_node, to_port)

func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)

func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for _graph_node in get_children():
		if _graph_node is GraphNode and _graph_node.name in nodes:
			_graph_node.queue_free()

func save(path: String = "") -> PackedByteArray:
	var _xml_nodes = [] # XMLNode
	var _graph_nodes = [] # GraphNode
	var xml_list = [] # all xml data in xml file
	var xml_doc = XMLDocument.new()

	xml_doc.root = XMLNode.new()
	xml_doc.root.name = "dma"
	for _graph_node in get_children():
		if _graph_node is not GraphNode:
			continue
		var _xml_node = XMLNode.new()
		_xml_node.name = "mech"
		_xml_node.attributes = {"name": _graph_node.name}
		_xml_nodes.append(_xml_node)
		_graph_nodes.append(_graph_node)
	
	for _parent_xml_node in _xml_nodes:
		for _connection in connections:
			if _parent_xml_node.attributes["name"] == _connection["from_node"]:
				for _child_xml_node in _xml_nodes:
					if _child_xml_node.attributes["name"] == _connection["to_node"]:
						for _parent_graph_node in _graph_nodes:
							if _parent_graph_node.name == _parent_xml_node.attributes["name"]:
								var _port_control_node = _parent_graph_node.get_child(_connection["from_port"])
								if _port_control_node is Label:
									_child_xml_node.attributes["connection"] = _port_control_node.text
								else:
									_child_xml_node.attributes["connection"] = "default"
						_parent_xml_node.children.append(_child_xml_node)
	for _root_xml_node in _xml_nodes:
		var _has_parent := false
		for _connection in connections:
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

func _on_child_order_changed() -> void:
	node_index = get_child_count() - 1
