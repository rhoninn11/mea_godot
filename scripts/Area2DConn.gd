extends Area2D
class_name Area2DConn

@export var main_node: Node2D

func _ready() -> void:
	assert(main_node)

func get_main_node() -> Node2D:
	return main_node
