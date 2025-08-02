extends GraphEdit


func _ready() -> void:
	graph_flush()

func graph_flush():
	if get_child_count() > 0:
		for _graph_node in get_children():
			if _graph_node is GraphNode:
				_graph_node.queue_free()
