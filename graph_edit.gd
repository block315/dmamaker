extends GraphEdit


func _ready() -> void:
	graph_flush()

func graph_flush():
	if get_child_count() > 0:
		for _graph_node in get_children():
			if _graph_node is GraphNode:
				_graph_node.queue_free()

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	connect_node(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for _graph_node in get_children():
		if _graph_node is GraphNode and _graph_node.name in nodes:
			_graph_node.queue_free()
