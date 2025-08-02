extends Tree

@export var enabled_set:Array[String] = []

func _ready() -> void:
	make_tree()

func _process(delta: float) -> void:
	pass

func make_tree(enabled_set:Array[String]=["SetA"]):
	var locomotion = create_item()
	locomotion.set_text(0,"Locomotion")
	locomotion.set_text(1,"Weight")
	var locomotion_air = create_item(locomotion)
	locomotion_air.set_text(0,"Air")
	var locomotion_land = create_item(locomotion)
	locomotion_land.set_text(0,"Land")
	var locomotion_land_wheel = create_item(locomotion_land)
	locomotion_land_wheel.set_text(0,"Wheel")
	locomotion_land_wheel.set_text(1, "5kg")
	var locomotion_sea = create_item(locomotion)
	locomotion_sea.set_text(0,"Sea")
	for _tree_item in locomotion.get_children():
		#if _tree_item is TreeItem:
			print(_tree_item)
			#_tree_item.set_text(0,_tree_item.)
